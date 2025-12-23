# User Journey Map V2 — The Pact

> **Last Updated:** 23 December 2025 (Phase 29)  
> **Author:** Manus AI (Acting CTO)  
> **Status:** ✅ Second Council Recommendations Integrated

---

## Executive Summary

This document maps the **newly proposed user journey**, incorporating the critical recommendations from the Second Council of Five (Kahneman, Brown, Hormozi, Zhuo, Ogilvy). The goal is to create a **"Value First, Identity Second"** flow that maximises user motivation and emotional safety before asking for commitment.

---

## Proposed New User Journey (Phase 29)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    OPTIMISED USER JOURNEY (Phase 29)                     │
│                      "Value First, Identity Second"                      │
└─────────────────────────────────────────────────────────────────────────┘

                              ┌──────────────┐
                              │   App Open   │
                              │  (Cold Start)│
                              └──────┬───────┘
                                     │
                                     ▼
                    ┌─────────────────────────────────┐
                    │  NEW: HOOK SCREEN (Kahneman K1) │
                    │  ─────────────────────────────  │
                    │  "People with witnesses are     │
                    │   3x more likely to succeed."   │
                    │                                 │
                    │  [Testimonial carousel]         │
                    │                                 │
                    │  "Don't rely on willpower.      │
                    │   Rely on your friends."        │
                    │                                 │
                    │  [Get Started] ← Primary CTA    │
                    │  [I have an invite] ← Secondary │
                    │                                 │
                    │  Progress: ○ ○ ○ (Step 0 of 3)  │
                    └──────────────┬──────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────┐
                    │  SCREEN 1: Identity (Revised)   │
                    │  ─────────────────────────────  │
                    │  "I want to become..."          │
                    │                                 │
                    │  [Mad-Libs chips with default]  │
                    │  [Custom input field]           │
                    │                                 │
                    │  "We measure progress, not      │
                    │   perfection. No streaks here." │
                    │   (Brown B1)                    │
                    │                                 │
                    │  [Continue with Google/Apple]   │
                    │                                 │
                    │  Progress: ● ○ ○ (Step 1 of 3)  │
                    └──────────────┬──────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────┐
                    │  SCREEN 2: Witness (Revised)    │
                    │  ─────────────────────────────  │
                    │  "Pick someone who'll celebrate │
                    │   your wins (and nudge you      │
                    │   when you slip)" (Ogilvy O2)   │
                    │                                 │
                    │  [Native Contact Picker]        │
                    │  [Privacy toggle: Show misses?] │
                    │   (Brown B3)                    │
                    │                                 │
                    │  [Add Supporter] ← Primary      │
                    │  [Start Solo] ← Secondary       │
                    │                                 │
                    │  Progress: ● ● ○ (Step 2 of 3)  │
                    └──────────────┬──────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────┐
                    │  SCREEN 3: Tier (Simplified)    │
                    │  ─────────────────────────────  │
                    │  [15-sec AI Coach audio sample] │
                    │   (Hormozi H2)                  │
                    │                                 │
                    │  ┌─────────┐  ┌─────────────┐   │
                    │  │  Solo   │  │  Coached    │   │
                    │  │  Free   │  │  Premium    │   │
                    │  │         │  │  + AI Voice │   │
                    │  └─────────┘  └─────────────┘   │
                    │   (Kahneman K4)                 │
                    │                                 │
                    │  Progress: ● ● ● (Step 3 of 3)  │
                    └──────────────┬──────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────┐
                    │  DASHBOARD (with celebration)   │
                    │  ─────────────────────────────  │
                    │  🎉 Confetti animation (Zhuo Z4)│
                    │                                 │
                    │  "Welcome, [Identity]!"         │
                    │                                 │
                    │  [Create Your First Pact]       │
                    └─────────────────────────────────┘
```

---

## Key Changes & Rationale

| Change | Advisor(s) | Rationale |
|--------|------------|-----------|
| **Hook Screen** | Kahneman, Hormozi, Ogilvy | **Lead with value.** Show the user the dream outcome and social proof *before* asking for any commitment. This engages System 1 thinking and increases motivation. |
| **Revised Identity Screen** | Brown, Kahneman | **Reduce cognitive load & fear.** Reframe identity as a selection, not a creation. Add "Graceful Consistency" messaging to create emotional safety. |
| **Revised Witness Screen** | Brown, Ogilvy | **Reframe as support, not judgement.** Change copy to be more encouraging. Add privacy controls to give users a sense of agency and safety. |
| **Simplified Tier Screen** | Kahneman, Hormozi | **Simplify the decision.** Reduce three choices to a binary (Free vs. Premium). Show the value of premium with an AI coach audio sample. |
| **Celebratory Dashboard** | Zhuo | **Create delight.** The first view of the dashboard should be a moment of celebration, reinforcing the user's decision and motivating them to take the next step. |

---

## Success Metrics (Updated)

| Metric | Current Baseline | Target (Phase 29) | Target (Phase 30) |
|--------|------------------|-------------------|-------------------|
| `hook_to_identity` | N/A (new screen) | 80% | 85% |
| `identity_entered` | ~80% | 95% | 98% |
| `auth_completed` | ~60% | 75% | 80% |
| `witness_added` | ~25% | 40% | 50% |
| `tier_selected` | ~90% | 95% | 98% |
| `onboarding_completed` | ~50% | 65% | 75% |
| `first_pact_created` | ~40% | 55% | 65% |
| `witness_to_creator` | ~5% | 20% | 30% |

---

*This document supersedes the previous User Journey Map. All future development should align with this new flow.*
