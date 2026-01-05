# Product Decisions & Open Questions

> **Purpose:** Central document for product vision, unresolved questions, and philosophy disagreements that influence development.
>
> **For AI Agents:** This document is the source of truth for product intent. When in doubt, consult this before making implementation decisions.

---

## 🔴 Critical Decisions Required

### 1. Sherlock Complexity vs Simplicity

**Current State:** The "Holy Trinity" (Anti-Identity, Failure Archetype, Resistance Lie) uses predefined archetypes that may be too simplistic.

**Concern:** Users are being bucketed into limited categories. Real human psychology is more nuanced.

**Question:** Should Sherlock:
- A) Use freeform extraction (let AI determine unique patterns per user)
- B) Use guided archetypes (current approach - faster, but potentially reductive)
- C) Hybrid (archetypes as starting points, refined over time)

**Decision:** _(Pending)_

---

### 2. Tier Placement & CAC Implications

**Current Flow:**
```
Identity → Permissions → Sherlock (AI Cost) → Loading → Reveal → Witness → Tier (Payment)
```

**Concern:** Sherlock consumes AI tokens BEFORE user commits to purchase. This may increase CAC with no revenue offset.

**Options:**
| Option | Flow | Pros | Cons |
|--------|------|------|------|
| A | Current | User is "invested" before paywall | Higher CAC |
| B | Tier First | `Identity → Tier → Sherlock` | Lower CAC, but less "magic" before payment |
| C | Freemium | Sherlock free, premium features gated | Sustainable but complex |

**MVP Decision:** Focus on **Tier 2 only** (no tiering complexity for MVP).

**Question:** Where should payment gate live?

**Decision:** _(Pending)_

---

### 3. Witness vs AI Accountability

**Current State:** Users can "Go Solo" or invite a human witness.

**Proposed Reframe:**
- Remove "Go Solo" concept
- The Pact AI IS the witness by default
- Human witness is an optional ADDITION (for referral/virality)

**Product Purpose of Witness Invite:**
- Primary: **User acquisition / referral tool**
- Secondary: Social accountability

**Decision:** _(Pending - needs UX design for "AI as default witness")_

---

### 4. Sensitivity Gate for Private Goals

**Concern:** Users with sensitive goals (porn addiction, substance abuse, eating disorders) may not want to share their Pact.

**Proposed Solution:**
- Add sensitivity detection during goal capture
- If sensitive: Skip witness invite, default to AI-only accountability
- Never prompt to share sensitive Pacts

**Keywords to detect:** `porn`, `addiction`, `drinking`, `eating`, `self-harm`, `gambling`, etc.

**Decision:** _(Pending - needs keyword list and UX design)_

---

### 5. LoadingInsightsScreen Purpose

**Current State:** Generic loading animation.

**Required Enhancement:**
- Show user-specific insights derived from Sherlock data
- Validate the "engine" and demonstrate personalization
- Not just a spinner — this is a value demonstration moment

**Example Insights:**
- "Your biggest risk: Sunday evenings (based on your Failure Archetype)"
- "We'll remind you at 7am (your peak energy window)"
- "Watch for: 'I'll do double tomorrow' — your Resistance Lie"

**Sprint:** Add to Phase 69+ roadmap

---

### 6. PactRevealScreen Personalization

**Current State:** Shows identity card with user's Pact.

**Required Enhancement:**
- Hyper-personalized content based on Holy Trinity
- May be too abstract to share — **store query for future user testing**

**Open Query:** _Do users actually want to share their Pact card? Track share button usage post-launch._

---

## 🟡 Branding Cleanup

### Remove "atomichabits" References

**Current:** URL scheme `atomichabits://invite?c={CODE}`

**Required:** Consolidate under `thepact.co` branding

**Actions:**
- [ ] Update AndroidManifest.xml URL scheme to `thepact://`
- [ ] Update iOS Info.plist URL scheme
- [ ] Update all docs referencing "atomichabits"
- [ ] Ensure deep links use `https://thepact.co/c/{CODE}`

---

## 🟢 Decided

### Invite Code Format
- **Format:** 8 characters alphanumeric
- **Charset:** `ABCDEFGHJKLMNPQRSTUVWXYZ23456789` (no ambiguous chars)
- **URL:** `https://thepact.co/c/{CODE}`
- **Purpose:** Witness invite codes (not onboarding gate)

### MVP Tier
- **Focus:** Tier 2 only
- **Rationale:** Reduce complexity, validate core value prop first

---

## 📚 Documentation Philosophy

### For AI-Driven Development

When working with AI agents (Claude, Gemini, etc.), maintain these documents:

| Document | Purpose |
|----------|---------|
| `PRODUCT_DECISIONS.md` | Product vision, open questions, philosophy |
| `AI_CONTEXT.md` | Technical context for AI understanding |
| `ROADMAP.md` | What's coming next |
| `CHANGELOG.md` | What's been done |
| `docs/adr/*.md` | Architecture Decision Records |

### Key Principle
> AI agents should be able to read these docs and understand not just WHAT to build, but WHY — including unresolved tensions and trade-offs.

---

## Appendix: Technical Concepts

### PopScope / WillPopScope

**What it is:** Flutter widget that intercepts the back button/gesture.

**Use cases:**
- **Block back:** Prevent leaving mid-Sherlock (would lose data)
- **Confirm back:** "Are you sure you want to leave?" dialog
- **Custom behavior:** Save draft before exiting

**Example (Confirm Dialog):**
```dart
PopScope(
  canPop: false,
  onPopInvoked: (didPop) async {
    if (didPop) return;
    final shouldLeave = await showDialog<bool>(...);
    if (shouldLeave == true) Navigator.pop(context);
  },
  child: Scaffold(...),
)
```

---

*Last Updated: 2026-01-05*
*Owner: Product Team*
