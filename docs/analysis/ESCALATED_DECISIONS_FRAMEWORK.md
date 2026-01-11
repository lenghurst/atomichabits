# Escalated Decisions Framework

> **Date:** 11 January 2026
> **Context:** Three decisions from Protocol 9 reconciliation require human input
> **Analysis Method:** Branching scenarios with opportunity cost, holistic codebase integration

---

## Decision Context Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     THE PACT MONETIZATION ARCHITECTURE                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ROADMAP.md:344 confirms: "Monthly Subscription" as primary model            │
│  PRODUCT_DECISIONS.md:2278 mentions: "Premium subscription → Unlimited"      │
│  CD-010: No dark patterns (artificial urgency, pay-to-win)                   │
│                                                                              │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐          │
│  │ DECISION 1      │    │ DECISION 2      │    │ DECISION 3      │          │
│  │ Shadow Cabinet  │───▶│ Token Earning   │───▶│ Consumable IAP  │          │
│  │ (Terminology)   │    │ (Mechanism)     │    │ (Monetization)  │          │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘          │
│         │                      │                       │                     │
│         ▼                      ▼                       ▼                     │
│  Affects: UI, Prompts,   Affects: Feature     Affects: Revenue,             │
│  Documentation           scope, UX loop       Premium value prop            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

# DECISION 1: Shadow Cabinet Terminology

## Current State

| Component | Current Name | Proposed Display Name |
|-----------|--------------|----------------------|
| `anti_identity_label` | Holy Trinity: Anti-Identity | **The Shadow** |
| `failure_archetype` | Holy Trinity: Failure Archetype | **The Saboteur** |
| `resistance_lie_label` | Holy Trinity: Resistance Lie | **The Script** |

**Database:** `identity_seeds` table has these fields
**Codebase Impact:** ~15 files reference Holy Trinity terminology (prompts, UI, services)

---

## Option A: Adopt Fully (Rename Everything)

### What It Means
- Rename database fields
- Update all 15+ files referencing Holy Trinity
- Documentation overhaul
- User-facing "Shadow Cabinet" everywhere

### Branching Scenario
```
YEAR 1 (IF ADOPTED FULLY):
├── Month 1: Database migration, field renames
│   └── Risk: Breaking changes to existing test users
├── Month 2: Documentation rewrite (20+ docs)
│   └── Cost: 2-3 sessions of documentation work
├── Month 3-12: All AI prompts use Shadow Cabinet
│   └── Benefit: Consistent metaphor in Council AI dialogue
│
YEAR 2+:
├── New developers onboard with single terminology
├── User research shows Shadow Cabinet resonates
└── No translation layer complexity
```

### Opportunity Cost
| What You Gain | What You Lose |
|---------------|---------------|
| Complete consistency | 1-2 weeks engineering time |
| Single mental model | Database migration risk |
| Clean documentation | Test user data disruption |
| Future-proof naming | Irreversible if Shadow Cabinet fails |

### Holistic Codebase Impact
- **Council AI (RQ-016):** Prompts can directly reference "Shadow" in dialogue
- **Onboarding (B-16):** Narrative Triangulation uses native terminology
- **GLOSSARY.md:** Single canonical name, no translation table

---

## Option B: Display Aliases (Recommended)

### What It Means
- Keep `anti_identity_label`, `failure_archetype`, `resistance_lie_label` in database
- Add application-layer translation: display as Shadow/Saboteur/Script
- Prompts use Shadow Cabinet language; code uses internal names

### Branching Scenario
```
YEAR 1 (IF DISPLAY ALIASES):
├── Week 1: Add translation layer (10 lines of code)
│   └── Cost: Minimal engineering
├── Month 1-3: A/B test Shadow Cabinet vs original terms
│   └── Benefit: Data-driven validation
├── Month 4-12: If successful, can migrate to Option A later
│   └── Flexibility preserved
│
YEAR 2+:
├── If Shadow Cabinet wins: Gradual field rename
├── If Shadow Cabinet fails: Display layer reverts easily
└── Developer onboarding requires translation table awareness
```

### Opportunity Cost
| What You Gain | What You Lose |
|---------------|---------------|
| Zero migration risk | Developer cognitive overhead |
| A/B testable | Two naming systems coexist |
| Reversible | Slightly messier codebase |
| Fast implementation | Documentation must explain mapping |

### Holistic Codebase Impact
- **Council AI:** Use Shadow Cabinet in user-facing dialogue, internal code uses fields
- **GLOSSARY.md:** Add 3-line translation table
- **AI Prompts:** "Display as 'The Shadow', stored as `anti_identity_label`"

---

## Option C: Defer (Keep Current Naming)

### What It Means
- Continue with Holy Trinity terminology
- Evaluate Shadow Cabinet post-launch based on user feedback
- Focus engineering on feature development

### Branching Scenario
```
YEAR 1 (IF DEFERRED):
├── Month 1-6: Ship with Holy Trinity
├── Month 6-12: User feedback collected
│   └── Risk: Users confused by "Holy Trinity" religious connotation
│   └── Risk: Harder to retrofit terminology later
│
YEAR 2:
├── If terminology issues arise: Full rewrite required
└── Retrofitting costs more than early adoption
```

### Opportunity Cost
| What You Gain | What You Lose |
|---------------|---------------|
| Zero work now | Narrative coherence |
| Ship faster | Parliament of Selves metaphor weakened |
| Engineering focus | Potential user confusion |

---

## Recommendation: B (Display Aliases)

**Rationale:**
1. **Risk/Reward:** Minimal engineering (10 LOC) for full narrative benefit
2. **Reversibility:** Can upgrade to Option A if validated, or revert if failed
3. **CD-015 Alignment:** Parliament of Selves → Shadow Cabinet strengthens metaphor
4. **Practical:** Users see improved language; code remains stable

**Confidence:** HIGH

---

# DECISION 2: Token Earning Mechanism

## Current State

**RQ-025 Research Finding:** Council Seals (1/week, 3 cap, no expiry, crisis bypass at 0.7)

**Your Question:** Have we discussed subscription providing X tokens per week/month?

**Answer:** ROADMAP.md:344 and PD-119 mention "Premium subscription = Unlimited" but did NOT explore a **metered subscription** (X tokens/month). This is a valid third path worth analyzing.

---

## Option A: Weekly Review (Behavioral Earning)

### What It Means
- Earn 1 token by completing 50+ character weekly reflection
- No subscription required for token access
- Tokens are purely behavioral currency

### Branching Scenario
```
YEAR 1 (IF WEEKLY REVIEW):
├── Month 1: Build Weekly Review screen
│   └── Cost: 3-5 days engineering (text input, validation, storage)
├── Month 2: User adoption curve
│   └── Expected: 40-60% complete first reflection
│   └── Drop: 20-30% weekly participation by month 3
├── Month 6: Reflection data accumulates
│   └── Benefit: Council AI context enriched
│   └── Benefit: User sees pattern in own reflections
│
YEAR 2+:
├── Power users: Rich reflection history
├── Casual users: May churn if reflection feels like "homework"
└── Monetization: Must find separate premium value
```

### Economy Simulation
| Week | Free User Tokens | Reflection Quality | Council Access |
|------|------------------|-------------------|----------------|
| 1 | 1 (gift) | N/A | 1 session |
| 2 | 1 (if reflected) | Variable | 2 sessions |
| 3 | 1 (if reflected) | Improving | 3 sessions (at cap) |
| 4+ | 1/week | Steady | Sustainable |

### Opportunity Cost
| What You Gain | What You Lose |
|---------------|---------------|
| Reflection → meaning loop | New feature (3-5 days) |
| Differentiation from competitors | User friction (some won't reflect) |
| Rich user data for AI | No direct revenue from tokens |
| psyOS philosophy alignment | Relies on intrinsic motivation |

---

## Option B: 7-Day Consistency (Streak-Based Earning)

### What It Means
- Earn 1 token by completing 4/7 days on any habit
- Simple, no new feature required
- Rewards existing behavior

### Branching Scenario
```
YEAR 1 (IF CONSISTENCY):
├── Week 1: Implement counter logic
│   └── Cost: 1-2 hours (existing streak infra)
├── Month 1-3: Users earn tokens easily
│   └── Benefit: Low friction
│   └── Risk: Tokens feel "cheap" (no meaning attached)
├── Month 6: Token hoarding at cap
│   └── Risk: No behavioral differentiation from competitors
│
YEAR 2+:
├── Users treat tokens as "expected" not "earned"
├── Grinding mentality reinforced (opposite of psyOS)
└── Harder to introduce reflection later
```

### Opportunity Cost
| What You Gain | What You Lose |
|---------------|---------------|
| Zero new features | Reflection opportunity |
| Fast implementation | psyOS differentiation |
| Low user friction | Meaningful token value |
| Leverages existing code | "Just another habit app" risk |

---

## Option C: Subscription with Token Allocation (Your Suggestion)

### What It Means
- Free users: Earn tokens via behavior (Weekly Review or consistency)
- Premium subscribers: Get X tokens per week/month automatically
- Hybrid model: Subscription = convenience, not requirement

### Branching Scenario
```
YEAR 1 (IF SUBSCRIPTION TOKENS):
├── Month 1: Build subscription infra + token allocation
│   └── Cost: 1-2 weeks (App Store/Play Store integration)
├── Month 2: Premium value proposition clear
│   └── "Free: Earn 1/week via reflection"
│   └── "Premium: Get 3/week automatically + still can reflect"
├── Month 6: Conversion funnel active
│   └── Free users who exhaust tokens → conversion prompt
│   └── Premium users never worry about tokens
│
YEAR 2+:
├── Predictable revenue (MRR)
├── Free users still viable (slower token access)
├── Premium = convenience, not paywall
└── Can adjust allocation without code changes
```

### Subscription Token Models

| Tier | Price | Tokens/Week | Council Access | Value Prop |
|------|-------|-------------|----------------|------------|
| **Free** | $0 | 1 (earned) | Limited | Try before buy |
| **Basic** | $4.99/mo | 2/week (auto) | Moderate | Casual user |
| **Premium** | $9.99/mo | Unlimited | Unrestricted | Power user |

**Alternative Simpler Model:**

| Tier | Price | Tokens | Notes |
|------|-------|--------|-------|
| **Free** | $0 | 1/week (earned) | Weekly Review required |
| **Premium** | $9.99/mo | Unlimited | No earning required |

### Opportunity Cost
| What You Gain | What You Lose |
|---------------|---------------|
| Clear monetization path | Subscription implementation time |
| Free tier remains viable | Complexity (two token sources) |
| Conversion funnel built-in | Risk of paywall perception |
| Predictable MRR | CD-010 requires careful design |

---

## Option D: Hybrid (Weekly Review + Subscription Boost)

### What It Means
- **Free users:** Weekly Review → 1 token/week
- **Premium users:** Weekly Review → 2 tokens/week + 1 auto-grant = 3/week
- Everyone reflects; premium gets bonus

### Branching Scenario
```
YEAR 1 (IF HYBRID):
├── Month 1: Build Weekly Review + subscription logic
│   └── Cost: 1-2 weeks total
├── Month 2: All users learn reflection habit
│   └── Free users: 1 token/week
│   └── Premium users: 3 tokens/week
├── Month 6: Reflection is universal behavior
│   └── Premium feels "worth it" (3x token rate)
│   └── Free users not locked out
│
YEAR 2+:
├── Reflection data from ALL users (not just free)
├── Premium = faster access, not exclusive access
├── CD-010 compliant (no pay-to-win, just pay-to-fast)
└── Upsell: "Reflect faster, grow faster"
```

### Opportunity Cost
| What You Gain | What You Lose |
|---------------|---------------|
| Best of both worlds | Most complex implementation |
| Universal reflection habit | Premium value must be clear |
| Fair free tier | Balancing token rates |
| CD-010 compliant | More UX states to design |

---

## Recommendation Matrix

| Criteria | A: Weekly Review | B: Consistency | C: Subscription | D: Hybrid |
|----------|------------------|----------------|-----------------|-----------|
| **psyOS Alignment** | **★★★** | ★ | ★★ | **★★★** |
| **Implementation Cost** | ★★ | **★★★** | ★ | ★ |
| **Revenue Potential** | ★ | ★ | **★★★** | **★★★** |
| **User Friction** | ★★ | **★★★** | ★★ | ★★ |
| **Differentiation** | **★★★** | ★ | ★★ | **★★★** |
| **CD-010 Compliance** | **★★★** | **★★★** | ★★ | **★★★** |

**Recommendation: D (Hybrid) or A (Weekly Review)**

**If monetization is priority:** Option D (Hybrid)
**If product philosophy is priority:** Option A (Weekly Review)

**Rationale for Hybrid:**
- Preserves the reflection → meaning loop (psyOS core)
- Creates clear premium value (3x token rate)
- Doesn't gate mental health support (Crisis Bypass unchanged)
- Revenue model without dark patterns

**Confidence:** MEDIUM-HIGH (needs user testing)

---

# DECISION 3: Consumable IAP Policy

## Current State

**CD-010:** No dark patterns (artificial urgency, pay-to-win)
**ROADMAP.md:344:** "Monthly Subscription" as structure
**PD-119:** Question 3: "Should premium users get unlimited tokens?"

---

## Option A: Free-Only MVP (No Monetization)

### What It Means
- Tokens earned only through behavior
- No purchase option whatsoever
- Premium subscription adds other value (voice coach, etc.)

### Branching Scenario
```
YEAR 1 (IF FREE-ONLY):
├── Month 1-6: Pure behavioral economy
│   └── Benefit: CD-010 fully compliant
│   └── Benefit: No "pay-to-win" perception
├── Month 6: User patterns established
│   └── Data: What % exhaust tokens regularly?
│   └── Data: Does scarcity drive engagement or churn?
│
YEAR 2:
├── If tokens drive engagement: Add subscription (Option C/D)
├── If tokens cause friction: Relax economy
└── User trust established before monetization
```

### Opportunity Cost
| What You Gain | What You Lose |
|---------------|---------------|
| User trust | Revenue from power users |
| CD-010 compliance | Conversion opportunity |
| Clean product story | Premium must find other value |
| No dark pattern risk | May undervalue Council feature |

---

## Option B: Optional Token Purchase (Consumable IAP)

### What It Means
- Users can buy token packs
- Example: $1.99 for 3 tokens, $4.99 for 10 tokens
- No subscription; pay-as-you-go

### Branching Scenario
```
YEAR 1 (IF CONSUMABLE):
├── Month 1: Build IAP infrastructure
│   └── Cost: 1 week (App Store/Play Store integration)
├── Month 2: Purchase patterns emerge
│   └── Risk: Power users buy tokens, never reflect
│   └── Risk: "Pay-to-win" perception
├── Month 6: Revenue vs reputation tradeoff
│   └── If users buy: Revenue stream
│   └── If users don't: IAP was wasted effort
│
YEAR 2:
├── Consumable creates "whale" dependency
├── CD-010 tension (is this a dark pattern?)
└── Behavioral loop undermined by purchase option
```

### Opportunity Cost
| What You Gain | What You Lose |
|---------------|---------------|
| Immediate revenue option | CD-010 compliance risk |
| User choice | Pay-to-win perception |
| Monetization without subscription | Reflection habit undermined |
| | Trust with users |

**Warning:** This option has the highest risk of violating CD-010 principles.

---

## Option C: Premium Subscription (Unlimited Tokens)

### What It Means
- Free users: Earn tokens through behavior
- Premium ($9.99/mo): Unlimited Council access
- No token counting for subscribers

### Branching Scenario
```
YEAR 1 (IF PREMIUM UNLIMITED):
├── Month 1: Build subscription with token bypass
│   └── Premium flag: Skip token check for Council
├── Month 2: Conversion messaging
│   └── "Upgrade to access Council anytime"
│   └── Risk: Feels like paywall
├── Month 6: User segmentation clear
│   └── Free: Casual, token-constrained
│   └── Premium: Power users, unlimited access
│
YEAR 2:
├── Clear value prop (unlimited vs limited)
├── Risk: Free tier feels "second class"
└── Premium subscription = primary revenue
```

### Opportunity Cost
| What You Gain | What You Lose |
|---------------|---------------|
| Clean subscription model | Free tier perceived value |
| Predictable MRR | "Paywall" perception risk |
| Power user satisfaction | Token economy becomes irrelevant for premium |
| Simple implementation | May undermine reflection habit for premium |

---

## Option D: Premium Subscription (Token Boost, Not Unlimited)

### What It Means
- Free users: 1 token/week (earned via Weekly Review)
- Premium ($9.99/mo): 3 tokens/week (auto-grant + bonus)
- Tokens still matter for everyone; premium is faster

### Branching Scenario
```
YEAR 1 (IF PREMIUM BOOST):
├── Month 1: Build subscription with token multiplier
│   └── Premium: 3 tokens/week vs 1
├── Month 2: Value prop is clear
│   └── "Access Council 3x more often"
│   └── Reflection still encouraged (bonus for reflecting)
├── Month 6: Both tiers viable
│   └── Free: Engaged, slower
│   └── Premium: Engaged, faster
│
YEAR 2:
├── Token economy meaningful for both tiers
├── No "second class" feeling
├── Premium value clear but not exclusive
└── Can adjust multiplier based on data
```

### Opportunity Cost
| What You Gain | What You Lose |
|---------------|---------------|
| Fair free tier | More complex than unlimited |
| Token economy preserved | Premium value may feel weak |
| Both tiers engage with tokens | Need to explain "why 3x?" |
| CD-010 compliant | Edge cases (cap, overflow) |

---

## Holistic Codebase Integration

### Current Monetization Infrastructure

From codebase analysis:
- `isPremium` field exists in `UserProfile`
- Dev Tools toggle for premium bypass
- `PactTierSelectorScreen` exists (Free vs Premium selection)
- Voice Coach gated behind premium
- Subscription intent: Monthly model confirmed

### Token Economy Integration Points

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      TOKEN ECONOMY INTEGRATION MAP                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  USER                                                                        │
│    │                                                                         │
│    ▼                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ Earning Layer                                                        │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                      │    │
│  │  [Weekly Review]  ──▶  +1 token/week (all users)                    │    │
│  │        +                                                             │    │
│  │  [Premium Sub]    ──▶  +2 tokens/week (auto-grant)                  │    │
│  │        =                                                             │    │
│  │  Free: 1/week | Premium: 3/week                                     │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│    │                                                                         │
│    ▼                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ Spending Layer                                                       │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                      │    │
│  │  [Council Summon]  ◀──  1 token (when tension < 0.7)                │    │
│  │                                                                      │    │
│  │  [Crisis Bypass]   ◀──  FREE (when tension ≥ 0.7)                   │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│    │                                                                         │
│    ▼                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ Schema (New Tables Required)                                         │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                      │    │
│  │  user_tokens: user_id, balance, last_earned_at, cap (3)             │    │
│  │  token_transactions: user_id, amount, type, created_at              │    │
│  │  weekly_reviews: user_id, content, created_at, tokens_earned        │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Final Recommendation Summary

| Decision | Recommended Option | Confidence | Rationale |
|----------|-------------------|------------|-----------|
| **1. Terminology** | B: Display Aliases | HIGH | Low risk, reversible, immediate narrative benefit |
| **2. Token Earning** | D: Hybrid (Review + Premium Boost) | MEDIUM-HIGH | Balances philosophy with monetization |
| **3. IAP Policy** | D: Premium Boost (not Unlimited) | MEDIUM-HIGH | Fair to free tier, CD-010 compliant |

### Combined Model

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      RECOMMENDED TOKEN ECONOMY                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  FREE TIER ($0)                                                              │
│  ├── Weekly Review completion: +1 token                                      │
│  ├── Token cap: 3                                                            │
│  ├── Crisis Bypass: Always free (tension ≥ 0.7)                             │
│  └── Council access: 1-3 sessions/month                                      │
│                                                                              │
│  PREMIUM TIER ($9.99/mo)                                                     │
│  ├── Weekly Review completion: +1 token (still encouraged!)                  │
│  ├── Auto-grant: +2 tokens/week                                              │
│  ├── Token cap: 3 (same as free)                                             │
│  ├── Crisis Bypass: Always free                                              │
│  ├── Council access: 3+ sessions/month                                       │
│  └── Bonus: AI-summarized reflection insights                                │
│                                                                              │
│  PHILOSOPHY:                                                                 │
│  "Premium doesn't replace reflection — it accelerates it."                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Awaiting Human Decision

| # | Decision | Options | Recommended |
|---|----------|---------|-------------|
| 1 | Shadow Cabinet Terminology | A: Full Adopt, B: Display, C: Defer | **B** |
| 2 | Token Earning Mechanism | A: Review, B: Consistency, C: Sub, D: Hybrid | **D** |
| 3 | Consumable IAP Policy | A: Free-Only, B: Consumable, C: Unlimited, D: Boost | **D** |

---

*Analysis complete. Human decision required to proceed.*
