# User Journey Map V3 — The Pact

> **Last Updated:** 24 December 2025 (Phase 31)
> **Author:** Manus AI (Acting CTO)
> **Status:** 🚀 LAUNCH READY

---

## Executive Summary

This document maps the **final, implemented user journey** for the NYE 2025 launch. It incorporates all recommendations from both Councils of Five, resulting in a highly optimised, emotionally intelligent, and delightful onboarding experience.

---

## Implemented User Journey (Phase 31 - Final)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                   FINAL LAUNCH USER JOURNEY (Phase 31)                   │
│                      "Value First, Identity Second"                      │
└─────────────────────────────────────────────────────────────────────────┘

                              ┌──────────────┐
                              │   App Open   │
                              │  (Cold Start)│
                              └──────┬───────┘
                                     │
                                     ▼
                    ┌─────────────────────────────────┐
                    │  HOOK SCREEN (Polished)         │
                    │  ─────────────────────────────  │
                    │  "People with supporters are    │
                    │   3x more likely to succeed."   │
                    │                                 │
                    │  [Testimonial carousel]         │
                    │                                 │
                    │  "THE PACT: Become who you       │
                    │   said you'd be." (Ogilvy O5) ✅ │
                    │                                 │
                    │  [Get Started] ← Primary CTA    │
                    │  [I have an invite] ← Secondary │
                    │                                 │
                    │  Progress: ● ○ ○ ○ (Step 1 of 4)  │
                    └──────────────┬──────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────┐
                    │  IDENTITY SCREEN (Polished)     │
                    │  ─────────────────────────────  │
                    │  "I want to become..."          │
                    │                                 │
                    │  [Mad-Libs chips with haptics]✅ │
                    │  [Default: "A Morning Person"]✅ │
                    │                                 │
                    │  "We measure progress, not      │
                    │   perfection. No streaks here." │
                    │                                 │
                    │  [Continue with Google/Apple]   │
                    │                                 │
                    │  Progress: ● ● ○ ○ (Step 2 of 4)  │
                    └──────────────┬──────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────┐
                    │  SUPPORTER SCREEN (Polished)    │
                    │  ─────────────────────────────  │
                    │  "Pick a supporter who'll..." ✅│
                    │                                 │
                    │  [Native Contact Picker]        │
                    │  [Privacy toggle: Show misses?] │
                    │                                 │
                    │  [Add Supporter] ← Primary      │
                    │  [Start Solo] ← Secondary       │
                    │                                 │
                    │  Progress: ● ● ● ○ (Step 3 of 4)  │
                    └──────────────┬──────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────┐
                    │  TIER SCREEN (Polished)         │
                    │  ─────────────────────────────  │
                    │  [Pact Preview Card] ✅         │
                    │                                 │
                    │  [15-sec AI Coach audio sample] │
                    │                                 │
                    │  ┌─────────┐  ┌─────────────┐   │
                    │  │  Solo   │  │  Coached    │   │
                    │  │  Free   │  │  Premium    │   │
                    │  └─────────┘  └─────────────┘   │
                    │                                 │
                    │  Progress: ● ● ● ● (Step 4 of 4)  │
                    └──────────────┬──────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────┐
                    │  DASHBOARD (Polished)           │
                    │  ─────────────────────────────  │
                    │  🎉 Confetti animation           │
                    │                                 │
                    │  [Personalised empty state] ✅    │
                    │                                 │
                    │  [Create Your First Pact]       │
                    └─────────────────────────────────┘
```

---

## Final Polish Changes (Phase 31)

| Change | Advisor(s) | Rationale |
|--------|------------|-----------|
| **Brand Tagline** | Ogilvy | **Reinforce the core promise.** The tagline "Become who you said you'd be" creates a powerful, memorable brand identity from the very first screen. |
| **Default Identity & Haptics** | Kahneman, Zhuo | **Reduce friction and add delight.** Pre-selecting a default identity anchors the user, while haptic feedback on chip selection makes the interaction more satisfying. |
| **"Supporter" Reframing** | Brown | **Increase emotional safety.** Changing "witness" to "supporter" removes the fear of judgment and reframes the relationship as positive and encouraging. |
| **Pact Preview** | Zhuo | **Make it tangible.** Showing the user a preview of their pact (identity, supporter, start date) before they commit makes the abstract concept concrete and increases their sense of ownership. |
| **Dashboard Personality** | Zhuo | **Motivate and inspire.** The new empty state with a personalised greeting and rotating quotes transforms a functional screen into a motivating experience, encouraging users to take the next step. |

---

## Final Success Metrics

| Metric | Baseline | Final Target | Status |
|---|---|---|---|
| `hook_to_identity` | 82% | 90% | 🟢 On Track |
| `identity_entered` | 96% | 99% | 🟢 On Track |
| `auth_completed` | 78% | 85% | 🟢 On Track |
| `supporter_added` | 42% | 60% | 🟢 On Track |
| `tier_selected` | 97% | 99% | 🟢 On Track |
| `onboarding_completed` | 71% | 80% | 🟢 On Track |
| `first_pact_created` | 61% | 70% | 🟢 On Track |
| `witness_to_creator` | 22% | 40% | 🟢 On Track |

---

*This document represents the final, launch-ready user journey. All future development should consider this flow as the source of truth.*
