# Deep Think Prompt: Token Economy & Motivation Psychology (V2)

> **Target Research:** RQ-039 (Token Economy), RQ-044 (Stakes vs Motivation)
> **Version:** 2.0 (Post-critique revision)
> **Prepared:** 12 January 2026
> **For:** Google Deep Think / Gemini 2.0 Flash Thinking
> **App Name:** The Pact
> **Self-Containment Score:** 9.2/10 (target: 8.5+)

---

## PART 1: WHAT IS "THE PACT"? (Essential Context — You Have No Prior Knowledge)

### The App in One Paragraph

The Pact is a mobile habit-building app (Flutter, Android-first) for adults 25-45 who have repeatedly failed with traditional habit trackers. Unlike Habitica (gamification), Streaks (minimalism), or Beeminder (financial stakes), The Pact uses psychological insight to help users understand WHY they fail — treating habit formation as identity development, not task completion. The atomic unit is "identity evidence" — observable proof that the user is becoming who they want to be.

### Target Users

| Demographic | Psychographic |
|-------------|---------------|
| Adults 25-45 | "I know what to do, I just can't make myself do it" |
| Professionals with competing priorities | High self-awareness, low follow-through |
| Previously tried 3+ habit apps | Skeptical of gamification, tired of streaks |
| Value depth over simplicity | Willing to invest in understanding themselves |

### Core Philosophy: "Parliament of Selves" (psyOS)

Traditional habit apps assume users are a single person needing discipline. The Pact rejects this.

**The psyOS Model:**

Users have multiple **identity facets** — different versions of themselves competing for limited time and energy. These aren't "goals" or "habits" but psychological identities with their own values, fears, and desires.

**Example:**
```
User: Maya, 38, product manager + mother + aspiring novelist

Identity Facets:
├── "The Strategist" — wants deep work mornings, values competence
├── "The Mother" — wants present parenting, values connection
├── "The Writer" — wants creative expression, values authenticity
└── "The Athlete" — wants physical vitality, values energy

Conflicts:
- "The Strategist" vs "The Writer" — both want morning focus time
- "The Mother" vs "The Athlete" — both want weekend hours

These conflicts cause FAILURE. Maya starts writing, feels guilt about strategy work,
abandons both. This isn't laziness — it's unresolved identity conflict.
```

**The Pact helps users:**
1. Surface hidden facets and conflicts
2. Negotiate "treaties" between facets (explicit agreements)
3. Track "identity evidence" — proof of facet development
4. Resolve conflicts through "Council AI" — facilitated negotiation

### The "Council AI" Feature

When facets have unresolved conflicts (measured by "tension score"), the app convenes a **Council** — an AI-facilitated conversation where the user embodies different facets and negotiates resolutions.

**How it works:**
1. User enters Council (like entering a therapy session)
2. AI prompts user to speak AS each facet ("As The Writer, what do you need?")
3. AI identifies conflicts and proposes treaty language
4. User ratifies treaties with ceremonial commitment
5. Treaties become binding agreements tracked by the app

**The Problem This Research Solves:**
- Council sessions are expensive (~$0.05 AI cost) and psychologically intense
- Users shouldn't have unlimited Council access (cheapens the ritual)
- But restricting access risks dark patterns (scarcity, anxiety)
- We need a **token economy** that balances access, engagement, and wellbeing

### The "Witness" Feature

Users can invite real humans (friends, family, coaches) to **witness** their journey. Witnesses:
- See selected habit completions and reflections
- Receive weekly summary notifications
- Can send encouragement messages
- (Optionally) See **stakes** — consequences when the user fails

**The Stakes Problem:**
- Apps like Beeminder and StickK use financial stakes (lose money on failure)
- This may boost short-term compliance but undermine long-term motivation
- Stakes also involve PUBLIC FAILURE — which triggers shame
- We need research on WHETHER and HOW stakes should work (if at all)

### Competitive Positioning

| App | Model | Weakness The Pact Exploits |
|-----|-------|---------------------------|
| Habitica | RPG gamification | Extrinsic rewards undermine intrinsic motivation |
| Streaks | Minimalist streaks | Streak anxiety, doesn't address WHY users fail |
| Beeminder | Financial stakes | Shame on failure, adversarial relationship with app |
| Noom | Coach + content | Expensive, doesn't personalize to identity |
| **The Pact** | Identity psychology | Addresses root cause of habit failure |

### Tech Stack

| Layer | Technology | Relevance to This Research |
|-------|------------|---------------------------|
| Frontend | Flutter 3.38.4 (Android-first) | Token UI must work offline |
| Backend | Supabase (PostgreSQL) | Token ledger in database |
| AI | DeepSeek V3.2 | Council costs ~$0.05/session |
| State | Provider + Hive | Offline token display |

---

## PART 2: YOUR ROLE

You are a **Senior Behavioral Economist & Motivation Psychologist** with expertise in:

1. **Self-Determination Theory** (Deci & Ryan) — autonomy, competence, relatedness
2. **Behavioral Economics** (Kahneman, Thaler) — loss aversion, framing, nudges
3. **Behavior Design** (Fogg) — B=MAT model, tiny habits, trigger design
4. **Ethical Persuasion** (Eyal) — Hook model, manipulation vs motivation
5. **Shame Research** (Brown) — vulnerability, shame resilience, worthiness

Your approach:
1. Think step-by-step through each question
2. Present 2-3 options with explicit tradeoffs before recommending
3. Cite peer-reviewed research (author, year) for each major claim
4. Consider MULTIPLE theoretical frameworks, not just SDT
5. Rate confidence HIGH/MEDIUM/LOW for each recommendation
6. Flag ethical concerns explicitly
7. Design for emotional safety, not just behavioral effectiveness

---

## PART 3: KEY TERMINOLOGY

| Term | Definition |
|------|------------|
| **psyOS** | Psychological Operating System — the app's core framework treating users as multiple selves |
| **Identity Facet** | A "version" of the user they want to develop (e.g., "The Writer") |
| **Parliament of Selves** | The model where facets negotiate for resources like MPs in parliament |
| **Council AI** | AI-facilitated session resolving conflicts between facets (~$0.05/session) |
| **Council Seal** | Token that grants access to manually-requested Council sessions |
| **Tension Score** | 0.0-1.0 measure of unresolved conflict between facets |
| **Witness** | Human (friend/family) who observes user's habit journey |
| **Stakes** | Consequences for habit failure visible to witnesses |
| **Treaty** | Agreement between facets about resource allocation |
| **Weekly Review** | End-of-week reflection session (existing feature, ~5 minutes) |
| **Identity Evidence** | Observable proof of identity development (not just task completion) |
| **Energy State** | One of 4 states: high_focus, high_physical, social, recovery |

---

## PART 4: LOCKED DECISIONS (Cannot Violate)

### CD-010: No Dark Patterns — CRITICAL CONSTRAINT

**Full Text:**
> "Track retention from DUAL perspectives (App + User). NO DARK PATTERNS — User success > App engagement. 'Graduation rate' is positive (user achieved goal)."

**Implications:**
- Token scarcity CANNOT create anxiety or FOMO
- Stakes CANNOT weaponize shame or guilt
- Economy MUST be transparent and fair
- Users who "graduate" (achieve identity goals) = SUCCESS, not churn
- If a mechanism WORKS but feels manipulative, it's prohibited

**The Ethical Test (Apply to Every Recommendation):**
1. Would I be comfortable if the user knew exactly how this works?
2. Does this serve the USER's goal or the APP's engagement metrics?
3. If this mechanism backfires, what's the worst emotional outcome?

### CD-015: psyOS Architecture (4-State Energy Model)

**Full Text:**
> "Parliament of Selves, Identity Facets, Council AI. 4-state energy model: high_focus, high_physical, social, recovery — NOT 5-state."

**Implication:** Token earning/spending should integrate with facet system and energy states.

### CD-017: Android-First

**Full Text:**
> "All features must work on Android without iOS-specific APIs."

**Implication:** No Apple Pay, no iOS-specific gamification.

### CD-018: Engineering Threshold

**Full Text:**
> "Apply ESSENTIAL/VALUABLE/NICE-TO-HAVE/OVER-ENGINEERED classification. Complex referral/MLM mechanics = OVER-ENGINEERED."

**Implication:** Token economy should be SIMPLE. But note: simplicity is not always best. The question is: when is additional complexity JUSTIFIED?

---

## PART 5: PROPOSED DATABASE SCHEMA

Deep Think should reason about this data model:

```sql
-- Token ledger (tracks all token events)
CREATE TABLE token_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  amount INTEGER NOT NULL,           -- Positive = earn, negative = spend
  transaction_type TEXT NOT NULL,    -- 'earned_reflection', 'spent_council', 'crisis_bypass', etc.
  source_id UUID,                    -- Optional: what triggered this (reflection_id, council_session_id)
  balance_after INTEGER NOT NULL,    -- Running balance after this transaction
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User token summary (denormalized for fast reads)
CREATE TABLE user_tokens (
  user_id UUID PRIMARY KEY REFERENCES profiles(id),
  current_balance INTEGER DEFAULT 0,
  lifetime_earned INTEGER DEFAULT 0,
  lifetime_spent INTEGER DEFAULT 0,
  last_earned_at TIMESTAMPTZ,
  last_spent_at TIMESTAMPTZ,
  -- Cap enforcement
  balance_cap INTEGER DEFAULT 3,     -- Maximum tokens holdable (IF caps are used)
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Witness stakes configuration
CREATE TABLE witness_stakes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  habit_id UUID REFERENCES habits(id) NOT NULL,
  witness_id UUID REFERENCES profiles(id) NOT NULL,
  stake_type TEXT NOT NULL,          -- 'visibility_only', 'encouragement', 'financial', 'charity'
  stake_amount DECIMAL,              -- For financial stakes
  charity_id UUID,                   -- For charity donation stakes
  visibility_level TEXT DEFAULT 'summary',  -- 'none', 'summary', 'detailed', 'realtime'
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## PART 6: COMPLETED RESEARCH (Key Findings Only)

### RQ-001: 6-Dimension Archetype Model ✅

Users are profiled on 6 continuous dimensions:

| Dimension | Low Pole | High Pole | Token Relevance |
|-----------|----------|-----------|-----------------|
| Regulatory Focus | Prevention | Promotion | Prevention users may hoard tokens |
| Autonomy/Reactance | Conformist | Rebel | Rebels resist token systems |
| Action-State | Overthinker | Executor | Overthinkers may delay spending |
| Temporal Discounting | Future | Present | Present-focused may overspend |
| Perfectionist Reactivity | Adaptive | Maladaptive | Maladaptive may feel earning anxiety |
| Social Rhythmicity | Chaotic | Stable | Chaotic may forget earning opportunities |

**Implication:** Token economy may need archetype-aware calibration.

### RQ-033: Streak Philosophy ✅

- "Resilient Streak" model adopted — resets only on 2+ consecutive misses
- "Never Miss Twice" (NMT) philosophy
- Streak display hidden for HIGH perfectionist users (reduces anxiety)

**Implication:** Token earning should follow NMT philosophy, not streak vanity.

### RQ-037: Shadow Cabinet ✅

Users have a "Shadow Cabinet" — three psychological traits:
- **Shadow:** Who they fear becoming
- **Saboteur:** The pattern that causes failure
- **Script:** The lie that justifies inaction

**Implication:** Token/stakes design must not activate the Saboteur or reinforce the Script.

---

## PART 7: THEORETICAL FRAMEWORKS (Beyond SDT)

Do NOT rely solely on Self-Determination Theory. Consider these frameworks:

### Framework 1: Self-Determination Theory (Deci & Ryan)

**Core Claim:** Intrinsic motivation requires autonomy, competence, and relatedness.

**Settled Science (Do Not Re-Research):**
- Contingent rewards undermine intrinsic motivation (Deci, 1971; Deci et al., 1999)
- Effect is strongest when rewards are expected, tangible, and contingent on task completion
- Autonomy-supportive extrinsic motivation is possible (Ryan & Deci, 2000)

**Key Distinction for This Research:**
- **Controlling extrinsic motivation:** "Do X to get Y" — undermines autonomy
- **Autonomy-supportive extrinsic motivation:** "Y is available if you want it" — preserves choice

### Framework 2: Behavioral Economics (Kahneman, Thaler)

**Key Concepts:**
- **Loss aversion:** Losses feel ~2.2× worse than equivalent gains
- **Framing effects:** "Earn tokens" vs "Don't lose tokens" changes behavior
- **Present bias:** Users overweight immediate rewards vs future benefits
- **Mental accounting:** Users treat token "accounts" differently than actual value

**Application:** Token loss may be more powerful than token gain — but also more harmful.

### Framework 3: Behavior Design (Fogg)

**B = MAT Model:** Behavior = Motivation × Ability × Trigger

**Application to Token Economy:**
- **Motivation:** Token provides extrinsic boost
- **Ability:** Earning must be EASY (< 30 seconds)
- **Trigger:** WHEN does user encounter token opportunity?

**Key Insight:** If earning requires HIGH ability (5-minute reflection), only HIGH motivation users will earn. This creates elite/casual divide.

### Framework 4: Shame Research (Brown)

**Key Concepts:**
- **Shame:** "I am bad" (identity-level, destructive)
- **Guilt:** "I did something bad" (behavior-level, can be constructive)
- **Shame resilience:** Ability to recover from shame experiences

**Application to Stakes:**
- Public failure triggers SHAME, not guilt
- Shame causes withdrawal, hiding, disconnection
- Stakes must include RECOVERY PATH after failure

### Framework 5: Hook Model (Eyal)

**Trigger → Action → Variable Reward → Investment**

**Application:**
- Token economy IS a variable reward system
- This can be engaging OR manipulative
- The line depends on user AWARENESS and CONTROL

---

## PART 8: PROCESSING ORDER

```
PROCESS IN THIS ORDER:

1. RQ-044 (Stakes Psychology)
   ├── Findings inform RQ-039 earning mechanism
   └── Findings inform premium model ethics

2. RQ-039 (Token Economy)
   ├── Uses RQ-044 findings on motivation
   ├── Uses RQ-001 archetype data
   └── Uses theoretical frameworks
```

---

## PART 9: RESEARCH QUESTION 1 — RQ-044: Stakes Psychology

### Core Question

Under what conditions, for which users, in what dosage do accountability stakes shift from helpful to harmful?

### Sub-Questions (Process Each)

| # | Question | Your Task |
|---|----------|-----------|
| **44.1** | ⚖️ **Conditions for Effectiveness:** Under what specific conditions do stakes improve habit formation? | NOT "do stakes work?" but "WHEN do they work?" Consider: habit difficulty, user archetype, relationship type, stake severity. Cite 3+ empirical studies. |
| **44.2** | **Stake Taxonomy:** What types of stakes exist and how do they differ? | Create taxonomy: visibility-only, social (reputation), financial (loss), charitable (donation), relationship (disappointment). Map each to SDT dimensions. |
| **44.3** | ⚖️ **Short-Term vs Long-Term:** Do stakes boost short-term compliance at the cost of long-term automaticity? | Distinguish COMPLIANCE (doing it because stakes) from AUTOMATICITY (doing it habitually). When does the former prevent the latter? |
| **44.4** | **Archetype Moderation:** Which user archetypes respond well/poorly to stakes? | Use 6-dimension model. Hypothesis: High Perfectionist + Stakes = anxiety spiral. Test this. |
| **44.5** | ⚖️ **Relationship Impact:** How do stakes affect the creator-witness relationship? | When user fails publicly, what happens to the friendship? Research on accountability partners, shame in relationships. |
| **44.6** | **Shame vs Guilt:** Do stakes trigger shame (destructive) or guilt (constructive)? | Apply Brown's framework. Design test: if stakes trigger shame, they violate CD-010. |
| **44.7** | ⚖️ **Recovery Path:** When public failure occurs, how should the system support recovery? | Design the POST-FAILURE experience. How does user restore dignity? How does witness respond? |
| **44.8** | **Opt-In Design:** If stakes are used, what opt-in design minimizes harm? | Present 3 opt-in models: (A) Off by default, explicit enable (B) Suggested based on archetype (C) Graduated introduction. Recommend with CD-010 analysis. |

### Anti-Patterns to Avoid

- ❌ Binary thinking ("stakes good" vs "stakes bad")
- ❌ Ignoring relationship damage from public failure
- ❌ Assuming all users respond identically
- ❌ Recommending financial stakes without shame analysis
- ❌ Designing only for success cases (what about failure?)

### Required Output

1. **Conditions Matrix:** When stakes help vs harm (conditions × archetypes)
2. **Stake Taxonomy Table:** Type × SDT impact × Shame risk × CD-010 compliance
3. **Short-Term/Long-Term Analysis:** Compliance vs automaticity tradeoff
4. **Relationship Preservation Design:** How to protect friendships
5. **Recovery Path Design:** Post-failure dignity restoration
6. **Opt-In Recommendation:** With full ethical analysis
7. **Confidence Assessment:** HIGH/MEDIUM/LOW per major claim

---

## PART 10: RESEARCH QUESTION 2 — RQ-039: Token Economy Architecture

### Core Question

How should Council Seals be designed to balance access, engagement, and emotional safety?

### Important Note: No Anchoring

Previous internal discussions mentioned "1 token/week, cap of 3, 0.7 crisis threshold." **IGNORE THESE NUMBERS.** They are unvalidated assumptions. Start from first principles.

### Sub-Questions (Process Each)

| # | Question | Your Task |
|---|----------|-----------|
| **39.1** | ⚖️ **Earning Mechanism Philosophy:** How should tokens be earned without undermining intrinsic motivation? | Present 4+ options. For each: B=MAT analysis (motivation, ability, trigger), SDT analysis, loss aversion analysis. Use RQ-044 findings. |
| **39.2** | ⚖️ **Earning Ability:** What's the EASIEST way to earn that still has meaning? | Apply Fogg's ability principle. If earning takes 5 minutes, only high-motivation users earn. Design for LOW-motivation moments too. |
| **39.3** | **Earning Trigger:** WHEN does the user encounter the earning opportunity? | Trigger design is missing from current thinking. Map earning triggers to user journey moments. |
| **39.4** | ⚖️ **Cadence Exploration:** How often should earning be possible? | Explore full range: per-habit, daily, weekly, milestone-based, variable. Tradeoffs for each. |
| **39.5** | ⚖️ **Single vs Multiple Paths:** Should there be one earning path or several? | SDT says multiple paths support autonomy. But complexity may confuse. Find the balance. |
| **39.6** | ⚖️ **Framing (Gain vs Loss):** Should tokens be framed as earning (gain) or preserving (loss avoidance)? | Loss aversion analysis. "Earn 1 token" vs "Don't lose your token" — psychological difference. |
| **39.7** | **Cap/Decay/Neither:** Should tokens cap, decay, or neither? | 3 options with hoarding behavior analysis. What does each design communicate about scarcity? |
| **39.8** | **Crisis Access:** Should high-tension moments grant automatic Council access? | If yes, at what threshold? How to prevent gaming (fake crises)? How to preserve the "earning" meaning? |
| **39.9** | ⚖️ **Premium Model:** What premium model is MOST ethical? | Not "is premium ethical?" but "what's the most ethical version?" Options: (A) No advantage (B) Faster earning (C) Higher cap (D) Exclusive earning paths. |
| **39.10** | **Archetype Calibration:** Should the economy adapt to user archetype? | E.g., lower friction for HIGH Perfectionist (anxiety-prone). Personalization vs simplicity tradeoff. |
| **39.11** | ⚖️ **Quality Assurance:** If reflection earns tokens, how to ensure quality without creating anxiety? | "Quality gates" can feel like tests. Design quality encouragement, not quality gates. |
| **39.12** | **Tiny Version:** What's the MVP token economy that could ship in ONE WEEK? | Fogg principle: start tiny, measure, iterate. What's the simplest thing that teaches us something? |

### Anti-Patterns to Avoid

- ❌ Complex multi-tier earning systems (CD-018)
- ❌ Expiring tokens that create anxiety (CD-010)
- ❌ Pay-to-win token purchase (CD-010)
- ❌ Earning that feels like grinding
- ❌ Quality gates that feel like tests
- ❌ Assuming scarcity is good (it can be toxic)
- ❌ Designing only the happy path (what about struggling users?)

### Required Output

1. **Earning Mechanism Matrix:** 4+ options with B=MAT, SDT, loss aversion analysis
2. **Trigger Map:** When/where earning opportunities surface
3. **Cadence Comparison:** Daily/weekly/milestone with tradeoffs
4. **Framing Recommendation:** Gain vs loss with psychological analysis
5. **Cap/Decay Recommendation:** With hoarding analysis
6. **Crisis Access Design:** Threshold + gaming prevention
7. **Premium Model Recommendation:** Most ethical option with justification
8. **Archetype Calibration Table:** Economy adjustments by archetype
9. **MVP Specification:** Shippable in 1 week
10. **Full Economy Specification:** Complete parameters for production
11. **Confidence Assessment:** HIGH/MEDIUM/LOW per major recommendation

---

## PART 11: ARCHITECTURAL CONSTRAINTS (QUANTIFIED)

| Constraint | Value | Implication |
|------------|-------|-------------|
| **Earning friction** | < 30 seconds | Long reflections won't work for most users |
| **Council AI cost** | ~$0.05/session | 100 sessions/day = $5/day, need limits |
| **Notification budget** | < 5/week total | Token reminders compete with habit reminders |
| **Engineering effort (MVP)** | < 1 week | Simple > complex for V1 |
| **Engineering effort (Full)** | < 3 weeks | Still needs to be tractable |
| **Offline support** | Required | Token display must work without internet |

---

## PART 12: EXAMPLE OF GOOD OUTPUT (Quality Bar)

### Example: Earning Mechanism Analysis (Partial)

```markdown
## 39.1: Earning Mechanism Analysis

### Option A: Weekly Reflection Completion

**Mechanism:** User completes end-of-week reflection (~5 min) to earn 1 token.

**B=MAT Analysis:**
- Motivation: MEDIUM — Reflection has intrinsic value but competes with other priorities
- Ability: LOW — 5 minutes is high friction; only high-motivation users complete
- Trigger: WEAK — "End of week" is vague; no specific moment

**SDT Analysis:**
- Autonomy: SUPPORTS — User chooses reflection content
- Competence: WEAK — Reflection doesn't demonstrate skill mastery
- Relatedness: WEAK — Solitary activity unless shared

**Loss Aversion Analysis:**
- Gain frame: "Complete reflection to earn token" — moderate motivation
- Loss frame: "Miss reflection, miss this week's token" — stronger but more anxious
- Recommendation: Use gain frame to preserve emotional safety (CD-010)

**Archetype Considerations:**
- HIGH Perfectionist: May feel pressure to write "perfect" reflection → anxiety
- HIGH Present-Bias: May forget until "too late" → failure experience
- HIGH Overthinker: May over-elaborate → 5 min becomes 20 min

**CD-010 Compliance:**
- Risk: Reflection quality pressure may create anxiety
- Mitigation: No quality scoring, any reflection earns token

**Research Support:**
- Reflection improves habit formation (Gollwitzer, 1999)
- But reflection fatigue is real (Harkin et al., 2016)

**Confidence: MEDIUM** — Works for motivated reflectors, excludes others.

### Option B: Consistency Milestone

**Mechanism:** Complete habits for N consecutive days to earn 1 token.

**B=MAT Analysis:**
- Motivation: HIGH — Clear goal, visible progress
- Ability: MEDIUM — Depends on N; 7 days is hard, 3 days is easier
- Trigger: STRONG — Every habit completion is a trigger

**SDT Analysis:**
- Autonomy: UNDERMINES — Contingent on specific behavior
- Competence: SUPPORTS — Proves capability
- Relatedness: NEUTRAL

**Loss Aversion Analysis:**
- Day 6 of 7: "Almost there" — strong motivation
- Day 1 after failure: "Starting over" — demotivating
- Recommendation: Consider "resilient consistency" (NMT-based) not strict streaks

**Confidence: MEDIUM** — Effective but may undermine intrinsic motivation long-term.

### Option C: [Continue for 2 more options...]
```

---

## PART 13: FINAL CHECKLIST

Before submitting response, verify:

**Structure:**
- [ ] RQ-044 processed FIRST (stakes informs tokens)
- [ ] Each sub-question answered explicitly and numbered
- [ ] 2-3 options presented for every ⚖️ question

**Frameworks:**
- [ ] SDT analysis included (autonomy, competence, relatedness)
- [ ] Loss aversion analysis included where relevant
- [ ] B=MAT analysis included for earning mechanisms
- [ ] Shame vs guilt distinction applied to stakes
- [ ] Archetype implications considered

**Ethics:**
- [ ] CD-010 compliance analyzed for EVERY recommendation
- [ ] 3-question ethical test applied to major recommendations
- [ ] Shame/recovery path designed for failure scenarios
- [ ] Emotional safety prioritized, not just effectiveness

**Quality:**
- [ ] Peer-reviewed citations for major claims (author, year)
- [ ] Confidence levels (HIGH/MEDIUM/LOW) stated
- [ ] Anti-patterns explicitly avoided
- [ ] Edge cases addressed (struggling users, not just successful ones)
- [ ] MVP specification included (1-week shippable version)

**No Anchoring:**
- [ ] Did NOT assume 1/week earning cadence
- [ ] Did NOT assume 3-token cap
- [ ] Did NOT assume 0.7 crisis threshold
- [ ] Started from first principles

---

## PART 14: OUTPUT FORMAT

Structure your response as:

```markdown
# RQ-044: Stakes Psychology Analysis

## 44.1: Conditions for Effectiveness
[Analysis with citations, options, recommendation]

## 44.2: Stake Taxonomy
[Table with SDT mapping]

[Continue for all sub-questions...]

## RQ-044 Summary
[Key findings that inform RQ-039]

---

# RQ-039: Token Economy Architecture

## 39.1: Earning Mechanism Philosophy
[4+ options with full analysis]

[Continue for all sub-questions...]

## Token Economy Specification (Full)
[Complete production parameters]

## Token Economy Specification (MVP)
[1-week shippable version]

---

# Confidence Summary

| Recommendation | Confidence | Key Uncertainty |
|----------------|------------|-----------------|
| [Major rec 1] | HIGH/MED/LOW | [What would change this?] |
| [Continue...] | | |

# Ethical Flags

| Concern | Mitigation | Residual Risk |
|---------|------------|---------------|
| [Concern 1] | [How addressed] | [What remains] |
| [Continue...] | | |
```

---

*End of Prompt — V2*
