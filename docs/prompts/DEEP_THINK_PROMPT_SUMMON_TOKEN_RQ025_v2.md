# Deep Think Prompt: Summon Token Economy (v2)

> **Target Research:** RQ-025, PD-119
> **Prepared:** 10 January 2026
> **For:** DeepSeek R1 Distilled (per CD-016)
> **App Name:** The Pact
> **Priority:** HIGH — User-requested for MVP, enables Council AI access strategy
> **Version:** 2.0 — Improved from v1 based on DEEP_THINK_PROMPT_GUIDANCE.md audit

---

## Your Role

You are a **Senior Game Economy Designer & Behavioral Economist** specializing in:
- In-app currency and token systems (freemium, gacha, subscription models)
- Behavioral economics (scarcity, loss aversion, endowment effect)
- Gamification psychology (Self-Determination Theory, variable reward)
- Monetization ethics in wellness/health apps
- Anti-gaming safeguards and exploit prevention

**Your approach:** Think step-by-step through the economic incentives. For each major design decision, present 2-3 economy models with explicit tradeoffs before recommending. Include a 90-day simulation for the recommended model. Balance engagement with user wellbeing. Design for long-term sustainability, not short-term engagement hacks.

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

## Prior Research Summary: Completed RQs That Inform This Research

### RQ-016: Council AI System ✅ COMPLETE
**Key Findings:**
- Turn Limit: 6 turns per session (hard cap)
- Activation Threshold: `tension_score > 0.7` triggers auto-summon
- Rate Limit: 1 auto-summon per 24h per conflict topic
- Session Cost: $0.02-0.10 depending on turn count and complexity
- Output: Draft treaty with terms + logic_hooks
- **Implication for RQ-025:** Token spend = $0.02-0.10 cost to business. Need to control access.

### RQ-021: Treaty Lifecycle ✅ COMPLETE
**Key Findings:**
- Treaties are agreements between identity facets
- Council AI drafts treaties; user ratifies with 3-second long-press
- Treaty success rate: ~60% lead to behavior change (hypothesis)
- Treaty failure rate: ~20% renegotiated within 7 days
- **Implication for RQ-025:** Successful treaties = high value. Token cost should reflect this.

### RQ-020: Conflict Detection ✅ COMPLETE
**Key Findings:**
- Tension score calculated from facet friction + scheduling conflicts
- Users experience 1-3 meaningful conflicts per month (typical)
- High-tension (>0.7) conflicts resolve faster than medium-tension (0.4-0.7)
- **Implication for RQ-025:** Token demand = ~1-3 per month for proactive users

### PD-109: Council AI Activation ✅ RESOLVED
**Decision:**
- **Automatic:** When `tension_score > 0.7` (no token required)
- **Manual:** When user spends Summon Token (bypasses threshold)
- Summon Token enables proactive conflict resolution

---

## Mandatory Context: Locked Decisions

### CD-015: psyOS Architecture ✅ CONFIRMED
- Parliament of Selves: Facets negotiate via Council AI
- Council AI resolves conflicts between identity facets
- High-value feature — should feel earned/ceremonial

### CD-016: AI Model Strategy ✅ CONFIRMED
- Council AI uses DeepSeek V3.2 (expensive, stateless)
- Each Council session = API cost ($0.02-0.10 depending on length)
- Rate limiting is necessary for cost control

### CD-010: Retention Philosophy ✅ CONFIRMED
- No dark patterns
- User success > app engagement
- "Graduated" users are success, not churn
- **CRITICAL:** Token scarcity must not create anxiety

### CD-018: Engineering Threshold ✅ CONFIRMED
- Solution must be VALUABLE or higher
- OVER-ENGINEERED = multi-currency system, elaborate earning trees

---

## Current State: Database Schema (Proposed)

```sql
-- User token balance
CREATE TABLE user_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  balance INT DEFAULT 0 CHECK (balance >= 0),
  lifetime_earned INT DEFAULT 0,
  lifetime_spent INT DEFAULT 0,
  last_earned_at TIMESTAMPTZ,
  last_spent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Token transaction log
CREATE TABLE token_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  amount INT NOT NULL,  -- positive = earned, negative = spent
  transaction_type TEXT CHECK (transaction_type IN ('earned', 'spent', 'gifted', 'expired')),
  source TEXT NOT NULL,  -- 'streak_7day', 'treaty_complete', 'onboarding_gift', 'council_summon'
  reference_id UUID,  -- FK to habit/treaty/council_session if applicable
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for common queries
CREATE INDEX idx_token_transactions_user ON token_transactions(user_id, created_at DESC);
CREATE INDEX idx_user_tokens_balance ON user_tokens(user_id) WHERE balance > 0;
```

---

## Resource Constraints (Quantified)

| Resource | Constraint | Budget |
|----------|------------|--------|
| **Council API Cost** | Per session (6 turns) | $0.02-0.10 |
| **Target Monthly Cost** | Per active user | < $0.50 |
| **Maximum Sessions** | Per user per month (budget-driven) | 5-10 |
| **Free User Access** | Minimum Council sessions/month | 2-3 (via tokens + auto-summon) |
| **Token Storage** | Per user | < 100 bytes |
| **Transaction Log** | Per user per month | < 1KB |
| **Complexity Threshold** | Single currency only | Per CD-018 |

---

## Research Question: RQ-025 — Summon Token Economy

### Core Question
How should the Summon Token gamification mechanic work to balance Council AI access, user engagement, and potential monetization?

### Why This Matters
- **UX Gating:** Without tokens, users can only access Council when tension is high
- **Cost Control:** Each Council session costs $0.02-0.10 (API calls)
- **Engagement Loop:** Tokens create earn-spend cycle that reinforces good habits
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

**IMPORTANT:** For questions marked with ⚖️, present 2-3 options with explicit tradeoffs before recommending.

| # | Question | Your Task |
|---|----------|-----------|
| **1** ⚖️ | **Economy Model Options:** What are viable token economy models? | Present 3 models: (A) Generous (easy earn, abundant access), (B) Balanced (weekly earn, monthly spend), (C) Scarce (achievement-gated, high-value). Include 90-day simulation for each. |
| **2** | **Earning Mechanics:** How are Summon Tokens earned? | Design 4-6 earning actions with token values, frequency caps, and anti-gaming safeguards. |
| **3** ⚖️ | **Earning Rate Tradeoff:** Fast earning (engagement) vs slow earning (value perception)? | Analyze tradeoff. Target: How many tokens should average user earn per week? |
| **4** | **Spending Cost:** What does it cost to summon Council? | Recommend token cost per session. Consider: 1 token (low friction) vs 2+ tokens (higher value). |
| **5** ⚖️ | **Token Cap Options:** Should there be a maximum accumulation? | Present options: (A) No cap, (B) Soft cap (reduced earning), (C) Hard cap. Analyze hoarding behavior. |
| **6** | **Token Expiry:** Do tokens expire? | Recommend policy. Consider CD-010 (no anxiety) vs engagement (use-it-or-lose-it). |
| **7** | **New User Bootstrap:** How do new users get their first token? | Design onboarding gift/tutorial. Balance: immediate access vs earned access. |
| **8** | **Anti-Gaming Safeguards:** How do we prevent exploit behaviors? | Identify 5+ gaming risks with specific safeguards for each. |
| **9** ⚖️ | **Monetization Path Options:** Should tokens be purchasable? | Present 3 options: (A) Free-only, (B) Optional purchase, (C) Premium subscription. Ethical analysis included. |
| **10** | **Success Metrics:** How do we know the token economy is healthy? | Define 6+ KPIs with targets, warning signs, and diagnostic actions. |

---

## Anti-Patterns to Avoid

- ❌ **Pay-to-play:** Don't make Council AI practically inaccessible without purchase
- ❌ **Inflation:** Don't make tokens so easy to earn they become meaningless
- ❌ **Deflation:** Don't make tokens so hard to earn users never access Council
- ❌ **FOMO:** Don't use expiry to create anxiety (violates CD-010)
- ❌ **Whale targeting:** Don't design for high-spending minority
- ❌ **Engagement hacking:** Don't reward behaviors that don't support habit formation
- ❌ **Complexity:** Don't create elaborate multi-currency systems (violates CD-018)
- ❌ **Hiding the system:** Don't make token earning opaque or manipulative
- ❌ **Single solution:** Present multiple economy models with tradeoffs

---

## Output Required

### Deliverable 1: Economy Model Options (Present 3 with Simulations)

| Model | Earn Rate | Spend Rate | 30-Day Balance | 90-Day Balance | Best For | Risk |
|-------|-----------|------------|----------------|----------------|----------|------|
| **A: Generous** | 2 tokens/week | 1 token/session | +4 tokens | +12 tokens | New users | Inflation |
| **B: Balanced** | 1 token/week | 1 token/session | +1 token | +3 tokens | Most users | None |
| **C: Scarce** | 1 token/2 weeks | 1 token/session | -1 token | -3 tokens | Power users | Deflation |

**Include 90-day simulation chart for recommended model:**

```
RECOMMENDED MODEL: [B: Balanced]

90-Day Token Flow Simulation (Regular User - 5 habits/week)

Week | Earned | Spent | Balance | Council Sessions | Notes
-----|--------|-------|---------|------------------|-------
  1  |   1    |   0   |    1    |        0         | Building tokens
  2  |   1    |   1   |    1    |        1         | First proactive summon
  3  |   1    |   0   |    2    |        0         | Saving for conflict
  4  |   1    |   1   |    2    |        1         | + auto-summon (high tension)
 ...
 12  |   1    |   1   |    3    |        1         | Stable equilibrium

Equilibrium State:
- Average balance: 2-3 tokens
- Monthly Council sessions: 2-3 (1 auto + 1-2 token)
- Monthly cost to business: ~$0.15-0.25
```

### Deliverable 2: Token Earning Specification

| Action | Tokens | Frequency Cap | Rationale | Anti-Gaming Safeguard |
|--------|--------|---------------|-----------|----------------------|
| [Action 1] | +N | Daily/Weekly/Once | [Why this reinforces habits] | [How to prevent gaming] |
| [Action 2] | +N | ... | ... | ... |
| [Action 3] | +N | ... | ... | ... |
| [Action 4] | +N | ... | ... | ... |
| [Action 5] | +N | ... | ... | ... |
| [Action 6] | +N | ... | ... | ... |

**Include Dart implementation:**

```dart
/// Token earning logic
class TokenEarningService {

  /// Award tokens for completed action
  Future<TokenAward?> checkAndAwardTokens(String userId, TokenAction action) async {
    // Check frequency cap
    final lastAward = await _getLastAwardForAction(userId, action);
    if (!_isWithinFrequencyCap(lastAward, action)) {
      return null;  // Already earned this period
    }

    // Check anti-gaming safeguards
    if (!await _passesAntiGamingChecks(userId, action)) {
      return null;  // Suspicious behavior detected
    }

    // Award tokens
    final award = TokenAward(
      amount: action.tokenValue,
      source: action.sourceId,
    );

    await _recordTransaction(userId, award);
    return award;
  }

  /// Actions that earn tokens
  static const Map<TokenAction, TokenConfig> earningActions = {
    TokenAction.weeklyConsistency: TokenConfig(
      tokens: 1,
      frequencyCap: Duration(days: 7),
      description: "Complete any habit 5+ days this week",
    ),
    // ... other actions
  };
}
```

### Deliverable 3: Token Economy Parameters

| Parameter | Value | Rationale | Alternative Considered |
|-----------|-------|-----------|------------------------|
| **Cost to Summon Council** | N tokens | [Why this cost] | [Why not higher/lower] |
| **Token Cap** | N (or unlimited) | [Behavioral rationale] | [Why not other option] |
| **Token Expiry** | N days (or never) | [CD-010 compliance] | [Why not other option] |
| **New User Gift** | N tokens | [Onboarding balance] | [Why not other option] |
| **Target Earn Rate** | N tokens/week | [Economy balance] | [Why not other option] |
| **Target Reserve** | N tokens | [User comfort level] | [Why not other option] |

### Deliverable 4: New User Onboarding Flow

```dart
/// New user token onboarding
class TokenOnboardingFlow {

  /// Day 1: Sherlock Protocol completion
  Future<void> onSherlockComplete(String userId) async {
    // Gift initial tokens
    await tokenService.giftTokens(
      userId: userId,
      amount: [N],  // TBD
      source: 'onboarding_gift',
    );

    // Show token tutorial
    await showTokenTutorial(
      message: "[Explain what tokens are for]",
      action: "[Show where to see balance]",
    );
  }

  /// Day 3-7: Earning explanation
  Widget buildEarningOpportunitiesCard() {
    return EarningCard(
      title: "Earn Summon Tokens",
      opportunities: [
        "[Opportunity 1 with progress indicator]",
        "[Opportunity 2 with progress indicator]",
      ],
    );
  }

  /// Day 7+: First conflict without tokens
  Widget buildNoTokensConflictUI(double tensionScore) {
    if (tensionScore > 0.7) {
      // Auto-summon available
      return AutoSummonPrompt();
    } else {
      // Show earning path
      return EarnTokensPrompt(
        message: "[Explain how to earn tokens]",
        fastestPath: "[Quickest way to earn 1 token]",
        // NO PURCHASE PROMPT unless monetization chosen
      );
    }
  }
}
```

### Deliverable 5: Anti-Gaming Safeguards

| Gaming Risk | Behavior | Probability | Safeguard | Detection Method |
|-------------|----------|-------------|-----------|------------------|
| Fake completions | Mark habits complete without doing | HIGH | [Safeguard] | [Detection] |
| App farming | Open app just for login rewards | MEDIUM | [Safeguard] | [Detection] |
| Referral fraud | Create fake accounts for bonuses | MEDIUM | [Safeguard] | [Detection] |
| Token hoarding | Never spend tokens | LOW | [Safeguard] | [Detection] |
| Multi-account | Use alt accounts for tokens | LOW | [Safeguard] | [Detection] |
| [Risk 6] | ... | ... | ... | ... |

### Deliverable 6: UI Specification (with Dart widgets)

```dart
/// Token display locations
class TokenUIComponents {

  /// 1. Dashboard header - always visible
  Widget buildDashboardTokenDisplay(int balance) {
    return TokenBadge(
      count: balance,
      icon: Icons.token,  // or custom icon
      tooltip: "Summon Tokens — use to convene Council AI",
    );
  }

  /// 2. Council summon button - context-aware
  Widget buildCouncilSummonButton({
    required int tokenBalance,
    required double tensionScore,
  }) {
    if (tensionScore > 0.7) {
      // Auto-summon available
      return PrimaryButton(
        label: "Convene Council (Auto)",
        enabled: true,
        cost: null,  // No token cost
      );
    } else if (tokenBalance > 0) {
      // Token summon available
      return PrimaryButton(
        label: "Convene Council",
        enabled: true,
        cost: TokenCost(amount: 1),
      );
    } else {
      // No access
      return DisabledButton(
        label: "Convene Council",
        reason: "Earn a token to summon",
        earnPath: "[Link to earning opportunities]",
      );
    }
  }

  /// 3. Profile/Settings - history and earning
  Widget buildTokenHistoryScreen() {
    return TokenHistoryScreen(
      sections: [
        TokenBalanceCard(),
        EarningOpportunitiesCard(),
        RecentTransactionsCard(),
      ],
    );
  }
}
```

### Deliverable 7: Monetization Analysis (Present 3 Options)

| Approach | Model | Pros | Cons | Ethical Rating | Recommendation |
|----------|-------|------|------|----------------|----------------|
| **A: Free-Only** | No purchase option | No monetization perception, CD-010 compliant | No revenue | ✅ Fully ethical | [Verdict] |
| **B: Optional Purchase** | Buy tokens (price TBD) | Revenue option, user choice | Pay-to-play perception | ⚠️ Requires care | [Verdict] |
| **C: Premium Sub** | Subscription = unlimited tokens | Predictable revenue | Excludes free users | ⚠️ Requires care | [Verdict] |

**If monetization chosen, include ethical guardrails:**
```
MONETIZATION GUARDRAILS (if Option B or C chosen):

1. FREE USERS MUST:
   - Access Council 2-3x/month without payment
   - Never see "pay to continue" during active conflict
   - Have clear earning path visible at all times

2. PAID TOKENS MUST:
   - Be reasonably priced ($0.99-1.99 for 3-5 tokens)
   - NOT be the only way to access Council
   - NOT create artificial scarcity

3. MESSAGING MUST:
   - Emphasize earning, not buying
   - Never shame free users
   - Frame purchase as "support the app" not "unlock feature"
```

### Deliverable 8: Health Metrics with Diagnostics

| Metric | Definition | Target | Warning Sign | Diagnostic Action |
|--------|------------|--------|--------------|-------------------|
| **Token Velocity** | Earned / Spent per user per month | 1.0-1.5 | <0.5 or >3.0 | Adjust earn rate |
| **Hoarding Rate** | % users at cap or max | <20% | >50% | Reduce cap or add spending incentive |
| **Zero Balance Frequency** | % users who hit 0 | <10% | >30% | Increase earn rate or gift tokens |
| **Council Access Rate** | Sessions per user per month | 2-3 | <1 | Check token availability |
| **Earn Completion Rate** | % of users who complete earning actions | >50% | <30% | Simplify earning |
| **API Cost per User** | Monthly Council cost | <$0.50 | >$1.00 | Reduce auto-summon rate |

### Deliverable 9: Confidence Assessment

| Recommendation | Confidence | Rationale | Follow-Up Needed |
|----------------|------------|-----------|------------------|
| Economy model (A/B/C) | HIGH/MEDIUM/LOW | [Why this model] | [Validation approach] |
| Earning mechanics | HIGH/MEDIUM/LOW | [Why these actions] | [A/B test plan] |
| Token cap decision | HIGH/MEDIUM/LOW | [Why cap/no cap] | [Monitoring plan] |
| Expiry decision | HIGH/MEDIUM/LOW | [Why expire/no expire] | [User feedback plan] |
| Monetization path | HIGH/MEDIUM/LOW | [Why this approach] | [Ethical review] |
| New user gift amount | HIGH/MEDIUM/LOW | [Why this amount] | [Retention analysis] |

---

## Example of Good Output: Economy Simulation

```markdown
### Recommended Economy Model: Balanced (Model B)

**Parameters:**
- Earn Rate: 1 token/week (via 7-day consistency)
- Spend Rate: 1 token/session
- New User Gift: 1 token
- Token Cap: 5 tokens (soft cap — can exceed via achievements)

**90-Day Simulation: Regular User (5 habits/week)**

| Week | Earned | Spent | Balance | Council Sessions | Auto-Summons | Notes |
|------|--------|-------|---------|------------------|--------------|-------|
| 1 | 1 (gift) | 0 | 1 | 0 | 0 | Onboarding complete |
| 2 | 1 | 0 | 2 | 0 | 0 | No conflict yet |
| 3 | 1 | 1 | 2 | 1 | 0 | First proactive summon |
| 4 | 1 | 0 | 3 | 0 | 1 | High-tension auto-summon |
| 5 | 1 | 1 | 3 | 1 | 0 | Used token for brewing conflict |
| 6 | 1 | 0 | 4 | 0 | 0 | Quiet week |
| 7 | 1 | 0 | 5 | 0 | 0 | Hit soft cap |
| 8 | 0 | 1 | 4 | 1 | 0 | Spent from cap |
| 9 | 1 | 0 | 5 | 0 | 1 | Back to cap + auto |
| 10 | 0 | 1 | 4 | 1 | 0 | Regular usage |
| 11 | 1 | 0 | 5 | 0 | 0 | Cap maintained |
| 12 | 0 | 1 | 4 | 1 | 0 | Equilibrium |

**Equilibrium Analysis:**
- Average balance: 4-5 tokens (feels "wealthy")
- Monthly Council sessions: 2-3 (1 auto + 1-2 token)
- Monthly API cost: $0.15-0.25 (within $0.50 budget)
- Zero-balance events: 0 (never runs out)

**Edge Case: Power User (daily habits, frequent conflicts)**

| Week | Earned | Spent | Balance | Council Sessions | Risk |
|------|--------|-------|---------|------------------|------|
| 1 | 1 | 2 | 0 | 2 | Runs out |
| 2 | 1 | 1 | 0 | 1 | Barely earning |

**Mitigation:** Achievement bonus tokens for power users (treaty success = +1)

**Edge Case: Casual User (2 habits/week, rare conflicts)**

| Week | Earned | Spent | Balance | Council Sessions | Risk |
|------|--------|-------|---------|------------------|------|
| 1 | 0 | 0 | 1 | 0 | Earning slowly |
| 2 | 0 | 0 | 1 | 0 | May not earn |

**Mitigation:** Lower consistency threshold (3 days = earn) for first month
```

---

## Concrete Scenario: Solve This

**Marcus's Token Journey (Full Scenario)**

Marcus joins The Pact on January 1st.

**Week 1:**
- Day 1: Completes Sherlock Protocol
- Day 1-7: Sets up 2 habits: "Morning Writing" and "Evening Walk"
- Completes habits 5 of 7 days (graceful consistency: 71%)
- Day 5: Notices conflict brewing between "Founder" and "Father" facets
- Tension_score: 0.45 (below 0.7 threshold)
- Wants to convene Council but unsure about tokens

**Walk through EXACTLY:**

1. **Day 1: What tokens does Marcus receive after Sherlock?**
   - Exact amount
   - UI presentation
   - Explanation shown

2. **Day 5: What does Marcus see about his token status?**
   - Balance display
   - Earning progress
   - Council access state

3. **Day 5: How can Marcus earn his first token (if needed)?**
   - Fastest path
   - Time to earn
   - Actions required

4. **Day 5: If Marcus has 0 tokens and tension is 0.45, what happens?**
   - UI state
   - Alternative offered
   - Frustration mitigation

5. **Day 7: Marcus earns a token and summons Council. What's the experience?**
   - Token spend UI
   - Confirmation
   - Post-session token state

6. **Week 2+: How quickly can Marcus earn another token?**
   - Earning path
   - Expected rate
   - Building reserve

---

## Industry References (with Analysis)

| App | Currency | Earning | Spending | Monetization | What We Learn |
|-----|----------|---------|----------|--------------|---------------|
| **Duolingo** | Gems | Lessons, streaks, ads | Streak freeze, hearts, outfits | Gem purchase, Super subscription | Gems are abundant; real scarcity is hearts (lives) |
| **Headspace** | None | N/A | N/A | Pure subscription | No gamification — focus on content value |
| **Habitica** | Gold/Gems | Tasks, habits, quests | Gear, features, cosmetics | Gem purchase | Complex economy; works for gamers, not mainstream |
| **Forest** | Coins | Focus sessions | Trees, real-tree donations | One-time purchase | Simple economy; donation angle adds meaning |

**Key Insight:** Successful wellness apps either (A) avoid token economies entirely (Headspace), or (B) keep them very simple (Forest). Complex economies (Habitica) alienate non-gamers.

**Recommendation:** Follow Forest model — simple earning, meaningful spending.

---

## Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Balanced** | Does the economy avoid both inflation and deflation? |
| **Tradeoff-Aware** | Did you present 2-3 economy models with simulations? |
| **Ethical** | Does it avoid dark patterns and anxiety creation? |
| **Sustainable** | Can this work long-term without major adjustments? |
| **Implementable** | Is Dart code provided for key logic? |
| **Measurable** | Are KPIs defined with targets and diagnostics? |
| **Flexible** | Does it allow future monetization without redesign? |
| **CD-010 Compliant** | Are dark patterns explicitly avoided? |

---

## Final Checklist Before Submitting

- [ ] Each sub-question (1-10) has explicit answer
- [ ] Questions marked ⚖️ have 2-3 options with tradeoff analysis
- [ ] Economy model options include 90-day simulations
- [ ] Earning specification includes all actions with safeguards (in table + Dart)
- [ ] Economy parameters are specific (not ranges) with rationale
- [ ] New user onboarding flow in Dart pseudocode
- [ ] Anti-gaming safeguards address 5+ risks with detection methods
- [ ] UI specification includes Dart widget code
- [ ] Monetization analysis is honest about ethical tradeoffs
- [ ] Health metrics have targets, warning signs, AND diagnostic actions
- [ ] Confidence levels stated for each major recommendation
- [ ] Marcus scenario solved with day-by-day walkthrough
- [ ] Anti-patterns explicitly avoided
- [ ] Solution respects CD-010 (no dark patterns verified)
- [ ] Integration with RQ-016, RQ-020, RQ-021 findings explicit
- [ ] Industry comparison included with actionable insights

---

*This prompt follows the DEEP_THINK_PROMPT_GUIDANCE.md quality framework (v2 improvements applied).*
