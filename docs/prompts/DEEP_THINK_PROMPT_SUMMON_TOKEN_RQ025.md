# Deep Think Prompt: Summon Token Economy

> **Target Research:** RQ-025, PD-119
> **Prepared:** 10 January 2026
> **For:** DeepSeek R1 Distilled (per CD-016)
> **App Name:** The Pact
> **Priority:** HIGH — User-requested for MVP, enables Council AI access strategy

---

## Your Role

You are a **Senior Game Economy Designer & Behavioral Economist** specializing in:
- In-app currency and token systems (freemium, gacha, subscription models)
- Behavioral economics (scarcity, loss aversion, endowment effect)
- Gamification psychology (Self-Determination Theory, variable reward)
- Monetization ethics in wellness/health apps
- Anti-gaming safeguards and exploit prevention

Your approach: Think step-by-step through the economic incentives created by token systems. Balance engagement with user wellbeing. Design for long-term sustainability, not short-term engagement hacks.

---

## Critical Instruction: Design Principles

```
SUMMON TOKEN PHILOSOPHY:
├── Tokens are ACCESS to Council AI, not reward currency
├── Earning tokens should reinforce GOOD habits (not just engagement)
├── Spending tokens should feel VALUABLE, not punitive
├── Economy must NOT create anxiety or dark patterns
└── Must work without ANY monetization (free app default)
```

**Key Constraint:** The Pact is NOT a free-to-play game. Tokens are a UX gating mechanism, not a monetization tool.

---

## Mandatory Context: Locked Architecture

### CD-015: psyOS Architecture ✅ CONFIRMED
- Parliament of Selves: Facets negotiate via Council AI
- Council AI resolves conflicts between identity facets
- High-value feature — should feel earned/ceremonial

### CD-016: AI Model Strategy ✅ CONFIRMED
- Council AI uses DeepSeek V3.2 (expensive, stateless)
- Each Council session = API cost ($0.02-0.10 depending on length)
- Rate limiting is necessary for cost control

### RQ-016: Council AI ✅ COMPLETE
- Turn Limit: 6 per session
- Activation: `tension_score > 0.7` OR Summon Token
- Rate Limit: 1 auto-summon per 24h per conflict topic
- Output: Draft treaty with terms + logic_hooks

### RQ-021: Treaty Lifecycle ✅ COMPLETE
- Treaties are agreements between identity facets
- Council AI drafts treaties during sessions
- Ratification requires 3-second ceremonial long-press

### PD-109: Council AI Activation ✅ RESOLVED
- **Automatic:** When `tension_score > 0.7`
- **Manual:** When user spends Summon Token
- Summon Token bypasses tension threshold

### CD-010: Retention Philosophy ✅ CONFIRMED
- No dark patterns
- User success > app engagement
- "Graduated" users are success, not churn

---

## Current State — The Gap

### RQ-021 Mention (Unspecified)

From RQ-021: *"Summon Token allows Council access below tension threshold"*

**Not Specified:**
- How tokens are earned
- What tokens cost to spend
- If there's a cap on token accumulation
- If tokens can be purchased
- If tokens expire
- How tokens are displayed in UI

### Proposed Earning Mechanisms (From RQ-025 Entry)

| Action | Tokens Earned | Rationale |
|--------|---------------|-----------|
| Complete habit streak (7 days) | +1 | Reward consistency |
| Successfully resolve Council treaty | +1 | Reward engagement |
| Refer a friend | +2 | Growth mechanic |
| Watch educational content | +1 | Engagement depth |
| Premium subscription | +3/month | Monetization |

**Status:** These are hypotheses, not validated designs.

---

## Research Question: RQ-025 — Summon Token Economy

### Core Question
How should the Summon Token gamification mechanic work to balance Council AI access, user engagement, and potential monetization?

### Why This Matters
- **UX Gating:** Without tokens, users can only access Council when tension is high
- **Cost Control:** Each Council session costs money (API calls)
- **Engagement Loop:** Tokens create earn-spend cycle
- **Monetization Option:** Could be future revenue source (but shouldn't be required)

### The Problem

**Scenario: Marcus Wants Council Access**

> Marcus has a simmering conflict between "The Founder" and "The Father" facets. His tension_score is 0.5 (below 0.7 threshold). He can see the conflict building but can't access Council AI yet.
>
> Marcus wants to convene the Council proactively before the conflict escalates. He sees he has 0 Summon Tokens.
>
> **Questions:**
> 1. How does Marcus earn his first token?
> 2. How long should it take to earn a token?
> 3. What if Marcus is a new user on Day 3 with no tokens?
> 4. Should Marcus be able to buy tokens?
> 5. What prevents Marcus from "gaming" the token system?

---

## Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| **1** | **Earning Mechanics:** How are Summon Tokens earned? | Design 4-6 earning actions with token values and rationale |
| **2** | **Earning Rate:** How long should it take to earn 1 token? | Propose target rate (e.g., "1 token per 7 days of active use") |
| **3** | **Spending Cost:** What does it cost to summon Council? | Propose token cost per session (1 token? More?) |
| **4** | **Token Cap:** Is there a maximum token accumulation? | Recommend cap (or no cap) with behavioral rationale |
| **5** | **Token Expiry:** Do tokens expire? | Propose expiry policy (or no expiry) with engagement analysis |
| **6** | **New User Bootstrap:** How do new users get their first token? | Design onboarding gift/tutorial integration |
| **7** | **Anti-Gaming:** How do we prevent exploit behaviors? | Identify 3-5 gaming risks and propose safeguards |
| **8** | **UI Display:** Where and how are tokens shown? | Propose UI placement with mockup description |
| **9** | **Monetization Path:** Should tokens be purchasable? | Analyze pros/cons, recommend with ethical considerations |
| **10** | **Success Metrics:** How do we know the token economy is healthy? | Define KPIs (token velocity, hoarding rate, purchase rate) |

---

## Anti-Patterns to Avoid

- ❌ **Pay-to-play:** Don't make Council AI practically inaccessible without purchase
- ❌ **Inflation:** Don't make tokens so easy to earn they become meaningless
- ❌ **Deflation:** Don't make tokens so hard to earn users never access Council
- ❌ **FOMO:** Don't use expiry to create anxiety
- ❌ **Whale targeting:** Don't design for high-spending minority
- ❌ **Engagement hacking:** Don't reward behaviors that don't support habit formation
- ❌ **Complexity:** Don't create elaborate multi-currency systems (OVER-ENGINEERED)
- ❌ **Hiding the system:** Don't make token earning opaque or manipulative

---

## Architectural Constraints (Hard Requirements)

| Constraint | Rule | Source |
|------------|------|--------|
| **Free Default** | App must be fully functional without spending money | Business model |
| **Council Cost** | Each session = $0.02-0.10 API cost | CD-016 |
| **Session Cap** | 6 turns per Council session | RQ-016 |
| **Tension Threshold** | 0.7 for auto-activation | PD-109 |
| **Rate Limit** | 1 auto-summon per 24h per topic | PD-109 |
| **No Dark Patterns** | Must not create anxiety or manipulation | CD-010 |
| **Android-First** | Must work on mobile UI | CD-017 |

---

## Token Economy Design Space

### Earning Dimension

| Earning Source | Pros | Cons | Risk |
|----------------|------|------|------|
| **Time-based** (daily login) | Predictable, fair | Rewards presence, not behavior | Gaming: open app, close |
| **Behavior-based** (habit completion) | Reinforces core value | Harder to predict | Gaming: mark fake completions |
| **Achievement-based** (milestones) | Feels earned, celebratory | Infrequent, unpredictable | Could frustrate new users |
| **Social-based** (referrals) | Growth, community | Not everyone wants to share | Spam risk, fake accounts |
| **Purchase-based** | Revenue, instant access | Pay-to-play perception | Whale dynamics |

### Spending Dimension

| Spend Target | Cost | Rationale |
|--------------|------|-----------|
| Summon Council (standard) | 1 token | Access to conflict resolution |
| Summon Council (urgent) | 0 tokens (tension > 0.7) | System-triggered, no cost |
| Extended session (+3 turns) | 1 token | For complex conflicts |
| [Other feature?] | ? | Expansion possibility |

### Economy Balance

```
HEALTHY ECONOMY:
├── Earn Rate: [X tokens per week of active use]
├── Spend Rate: [Y tokens per month for average user]
├── Net Balance: [Slight surplus — users should feel wealthy, not poor]
├── Reserve Target: [Users should aim to hold Z tokens]
└── Velocity: [Tokens should flow, not hoard]
```

---

## Output Required

### Deliverable 1: Token Earning Specification

| Action | Tokens | Frequency Cap | Rationale | Anti-Gaming Safeguard |
|--------|--------|---------------|-----------|----------------------|
| [Action 1] | +N | Daily/Weekly/Once | Why this action | How to prevent gaming |
| [Action 2] | +N | ... | ... | ... |
| ... | ... | ... | ... | ... |

### Deliverable 2: Token Economy Parameters

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| **Cost to Summon Council** | N tokens | ... |
| **Token Cap** | N (or unlimited) | ... |
| **Token Expiry** | N days (or never) | ... |
| **New User Gift** | N tokens | ... |
| **Target Earn Rate** | N tokens/week | ... |
| **Target Reserve** | N tokens | ... |

### Deliverable 3: New User Onboarding Flow

```
DAY 1: User completes Sherlock Protocol
├── [Token gift? How many?]
├── [UI explanation of tokens?]
└── [First Council session included?]

DAY 3-7: User builds habits
├── [Earning opportunities]
├── [Token balance display]
└── [Council preview/teaser?]

DAY 7+: User encounters first conflict
├── [If tension < 0.7 and 0 tokens?]
├── [How to unlock Council access?]
└── [Frustration mitigation]
```

### Deliverable 4: Anti-Gaming Safeguards

| Gaming Risk | Behavior | Safeguard |
|-------------|----------|-----------|
| Fake completions | Marking habits complete without doing them | ... |
| App open/close farming | Opening app just for login rewards | ... |
| Referral fraud | Fake accounts for referral bonuses | ... |
| [Risk 4] | ... | ... |
| [Risk 5] | ... | ... |

### Deliverable 5: UI Specification

```
TOKEN DISPLAY LOCATIONS:

1. Dashboard Header:
   └── [What user sees: icon, count, tooltip?]

2. Council Summon Button:
   └── [State when tokens available vs unavailable]

3. Profile/Settings:
   └── [Token history, earning opportunities]

4. Notifications:
   └── [When user earns/spends tokens]
```

### Deliverable 6: Monetization Analysis (Optional Path)

| Approach | Pros | Cons | Recommendation |
|----------|------|------|----------------|
| **Free only** | No monetization perception | No revenue from feature | ... |
| **Token purchase** | Direct revenue | Pay-to-play risk | ... |
| **Premium subscription** | Predictable revenue | Excludes free users | ... |
| **Hybrid** | Flexibility | Complexity | ... |

### Deliverable 7: Health Metrics

| Metric | Definition | Target | Warning Sign |
|--------|------------|--------|--------------|
| **Token Velocity** | Earn rate / Spend rate | 1.0-1.5 | <0.5 (deflation) or >3 (inflation) |
| **Hoarding Rate** | % users with max tokens | <20% | >50% (tokens not valued) |
| **Zero Balance Frequency** | % users who hit 0 | <10% | >30% (frustration risk) |
| **Council Access Rate** | Sessions per user per month | 1-3 | <0.5 (underutilized) |

### Deliverable 8: Confidence Levels

| Recommendation | Confidence | Rationale |
|----------------|------------|-----------|
| Earning mechanics | HIGH/MEDIUM/LOW | ... |
| Economy parameters | HIGH/MEDIUM/LOW | ... |
| Anti-gaming safeguards | HIGH/MEDIUM/LOW | ... |
| Monetization path | HIGH/MEDIUM/LOW | ... |

---

## Example of Good Output: Behavior-Based Earning

```markdown
### Earning Action: 7-Day Consistency Streak

**Token Value:** +1 Summon Token

**Definition:**
Complete any tracked habit for 7 consecutive days. Does NOT require:
- Perfect streak (80%+ graceful consistency counts)
- Same habit (any habit qualifies)
- Full version (tiny version counts)

**Frequency Cap:** 1 per habit per 7-day cycle

**Rationale:**
- Reinforces core app value (habit consistency)
- Achievable for engaged users (~weekly)
- Creates predictable earn rate for planning

**Anti-Gaming Safeguard:**
- Minimum habit complexity: Must be a "real" habit (not "Drink water")
- Witness verification: If habit has witness, requires no disputed completions
- Velocity limit: Max 2 tokens from this action per week (multiple habits)

**Psychology:**
- Ties reward to desired behavior
- 7 days = enough effort to feel earned
- Supports "Never Miss Twice" philosophy (80% threshold)
```

---

## Concrete Scenario: Solve This

**Marcus's Token Journey (Full Scenario)**

Marcus joins The Pact on January 1st.

**Week 1:**
- Completes Sherlock Protocol (Day 1)
- Sets up 2 habits: "Morning Writing" and "Evening Walk"
- Completes habits 5 of 7 days (graceful consistency: 71%)
- Day 5: Notices conflict brewing between "Founder" and "Father" facets
- Tension_score: 0.45 (below 0.7 threshold)
- Has 0 Summon Tokens
- Wants to convene Council but can't

**Questions to Answer:**
1. Should Marcus have received any tokens by Day 5? How many?
2. What does Marcus see in the UI about his token status?
3. How can Marcus earn his first token fastest?
4. If Marcus can't access Council, what alternative is offered?
5. When Marcus earns his first token and summons Council, what's the experience?
6. After spending the token, how quickly can Marcus earn another?

Walk through the complete token journey for this scenario.

---

## Industry References

Consider (but don't copy) these token/currency systems:

| App | Currency | Earning | Spending | Monetization |
|-----|----------|---------|----------|--------------|
| **Duolingo** | Gems/Lingots | Lessons, streaks | Streak freeze, outfits | Purchase gems |
| **Headspace** | N/A (subscription) | — | — | Pure subscription |
| **Habitica** | Gold/Gems | Tasks, habits | Gear, features | Purchase gems |
| **Forest** | Coins | Focus sessions | Trees, donations | One-time purchase |

---

## Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Balanced** | Does the economy avoid both inflation and deflation? |
| **Ethical** | Does it avoid dark patterns and anxiety creation? |
| **Sustainable** | Can this work long-term without major adjustments? |
| **Implementable** | Can we build this with current architecture? |
| **Measurable** | Can we track economy health with clear metrics? |
| **Flexible** | Does it allow future monetization without redesign? |

---

## Final Checklist Before Submitting

- [ ] Each sub-question (1-10) has explicit answer
- [ ] Earning specification includes all actions with safeguards
- [ ] Economy parameters are specific (not ranges)
- [ ] New user onboarding flow is day-by-day
- [ ] Anti-gaming safeguards address 5+ risks
- [ ] UI specification includes all touchpoints
- [ ] Monetization analysis is honest about tradeoffs
- [ ] Health metrics have targets AND warning signs
- [ ] Confidence levels stated for each major recommendation
- [ ] Marcus scenario solved with complete token journey
- [ ] Anti-patterns explicitly avoided
- [ ] Solution respects CD-010 (no dark patterns)

---

*This prompt follows the DEEP_THINK_PROMPT_GUIDANCE.md quality framework.*
