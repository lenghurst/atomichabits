# User Journey Map — The Pact

> **Last Updated:** 23 December 2025 (Phase 28.5)  
> **Author:** Manus AI (Acting Head of Architecture)  
> **Status:** ✅ Council of Five Optimisations Implemented

---

## Executive Summary

This document maps the complete new user journey for **The Pact**, updated to reflect the **Council of Five** optimisations implemented in Phase 28.4. It details how these changes address previously identified friction points and create a more persuasive, lower-friction onboarding experience.

---

## 1. User Entry Points (Acquisition Channels)

The Pact has **6 distinct entry points**, each with different user intent and context:

| Entry Point | Route | User Intent | Current State |
|-------------|-------|-------------|---------------|
| **Organic Install** | `/` → `IdentityAccessGateScreen` | Curious, exploring | ✅ Working |
| **Invite Deep Link** | `/witness/accept/:code` | High intent, social proof | ✅ Working |
| **Install Referrer** | Play Store → `/witness/accept/:code` | High intent, deferred | ✅ Working |
| **Niche Landing** | `/devs`, `/writers`, `/scholars`, etc. | Targeted, niche-specific | ✅ Routes to Identity First flow with preset identity |
| **Clipboard Bridge** | Clipboard check → `/witness/accept/:code` | Fallback for failed links | ✅ Working |
| **Direct Marketing** | `thepact.co` → App Store | Awareness, brand-driven | ✅ Working |

---

## 2. The "Identity First" Onboarding Flow (Primary Path)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        NEW USER JOURNEY MAP                              │
│                     "Identity First" Flow (Phase 27.17)                  │
└─────────────────────────────────────────────────────────────────────────┘

                              ┌──────────────┐
                              │   App Open   │
                              │  (Cold Start)│
                              └──────┬───────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    ▼                ▼                ▼
           ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
           │ Organic User │  │ Invite Link  │  │ Install      │
           │ (No Context) │  │ (Deep Link)  │  │ Referrer     │
           └──────┬───────┘  └──────┬───────┘  └──────┬───────┘
                  │                 │                 │
                  │                 └────────┬────────┘
                  │                          │
                  ▼                          ▼
    ┌─────────────────────────┐    ┌─────────────────────────┐
    │  SCREEN 1: Identity     │    │  "RED CARPET" FLOW      │
    │  Access Gate            │    │  (Invited Users)        │
    │  ────────────────────   │    │  ────────────────────   │
    │  • **Identity Mad-Libs**  │    │  • Skip to Witness      │
    │  • **Mandatory Identity** │    │    Accept Screen        │
    │  • **Preset from Route**  │    │  • Show contract first  │
    │  • Google/Apple OAuth   │    │  • Auth AFTER viewing   │
    │  • DEV mode toggle      │    │                         │
    └──────────┬──────────────┘    └──────────┬──────────────┘
               │                              │
               ▼                              ▼
    ┌─────────────────────────┐    ┌─────────────────────────┐
    │  SCREEN 2: Pact Witness │    │  Witness Accept Screen  │
    │  ────────────────────   │    │  ────────────────────   │
    │  • **Native Contact**   │    │  • View friend's pact   │
    │    **Picker**           │    │  • Tap-hold to sign     │
    │  • Manual fallback      │    │  • Wax seal ceremony    │
    │  • Start solo (opt)     │    │  • **Reciprocity Loop**   │
    └──────────┬──────────────┘    └──────────┬──────────────┘
               │                              │
               ▼                              ▼
    ┌─────────────────────────┐    ┌─────────────────────────┐
    │  SCREEN 3: Tier Select  │    │  Auth Required Dialog   │
    │  ────────────────────   │    │  ────────────────────   │
    │  • Free ($0)            │    │  • "Sign in to seal"    │
    │  • **Trust Grant Dialog** │    │  • Google/Apple OAuth   │
    │    (for Premium Tiers)  │    │  • Then complete seal   │
    └──────────┬──────────────┘    └──────────┬──────────────┘
               │                              │
               └──────────────┬───────────────┘
                              │
                              ▼
                    ┌─────────────────────────┐
                    │  DASHBOARD              │
                    │  ────────────────────   │
                    │  • Habit list           │
                    │  • Create first pact    │
                    │  • AI Coach access      │
                    └─────────────────────────┘
```

---

## 3. Critical Decision Points

### Decision Point 1: Identity Declaration
**Location:** `IdentityAccessGateScreen`  
**Question:** "Who are you committed to becoming?"

| User Action | Outcome | Friction Level |
|-------------|---------|----------------|
| Enters identity + Google OAuth | Proceeds to Screen 2 | 🟢 Low |
| Enters identity + Email signup | Proceeds to Screen 2 | 🟡 Medium |
| Skips identity + OAuth | Identity stored as empty | 🔴 High (lost context) |
| Taps DEV mode | Enables developer tools | N/A |

**Resolution (Clear):** The identity field is now **mandatory**. The "Identity Mad-Libs" chip selector provides examples and reduces friction, making the requirement feel less like a burden and more like a helpful step.

---

### Decision Point 2: Witness Selection
**Location:** `PactWitnessScreen`  
**Question:** "Add a witness or start solo?"

| User Action | Outcome | Friction Level |
|-------------|---------|----------------|
| Adds witness (email/phone) | Invite sent, proceeds | 🟡 Medium |
| Starts solo | Proceeds without witness | 🟢 Low |
| Abandons | Lost user | 🔴 Critical |

**Resolution (Fogg):** The witness input now uses a **native contact picker**. This dramatically reduces friction and input errors. A manual entry field remains as a fallback.

---

### Decision Point 3: Tier Selection
**Location:** `PactTierSelectorScreen`  
**Question:** "Choose your tools"

| User Action | Outcome | Friction Level |
|-------------|---------|----------------|
| Selects Free | Proceeds to dashboard | 🟢 Low |
| Selects Builder | Should trigger payment flow | ⚠️ Not implemented |
| Selects Ally | Should trigger payment flow | ⚠️ Not implemented |

**Resolution (Bezos):** Instead of a paywall, premium tiers now trigger a **"Trust Grant" dialog**. This grants early adopters free lifetime access, building a loyal user base and capturing high-intent signals for future monetisation strategies.

---

## 4. The "Red Carpet" Flow (Invited Users)

Invited users have **higher intent** and should experience a **shorter, more focused** journey.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     INVITED USER JOURNEY                                 │
│                   "The Red Carpet" (Phase 24)                            │
└─────────────────────────────────────────────────────────────────────────┘

    User A shares link                User B receives link
    ─────────────────                 ─────────────────────
    thepact.co/join/ABCD1234    →     Clicks link on mobile
                                              │
                                              ▼
                                      ┌───────────────────┐
                                      │ OS Detection      │
                                      │ (Landing Page)    │
                                      └─────────┬─────────┘
                                                │
                          ┌─────────────────────┼─────────────────────┐
                          │                     │                     │
                          ▼                     ▼                     ▼
                   ┌─────────────┐       ┌─────────────┐       ┌─────────────┐
                   │ iOS         │       │ Android     │       │ Desktop     │
                   │ App Store   │       │ Play Store  │       │ Email       │
                   │ + referrer  │       │ + referrer  │       │ Capture     │
                   └──────┬──────┘       └──────┬──────┘       └─────────────┘
                          │                     │
                          └──────────┬──────────┘
                                     │
                                     ▼
                          ┌─────────────────────┐
                          │ App Opens           │
                          │ DeepLinkService     │
                          │ checks:             │
                          │ 1. Direct link      │
                          │ 2. Install referrer │
                          │ 3. Clipboard        │
                          └─────────┬───────────┘
                                    │
                                    ▼
                          ┌─────────────────────┐
                          │ WitnessAcceptScreen │
                          │ ─────────────────── │
                          │ • Shows friend's    │
                          │   pact details      │
                          │ • Tap-hold to sign  │
                          │ • Wax seal drops    │
                          └─────────┬───────────┘
                                    │
                          ┌─────────┴─────────┐
                          │                   │
                          ▼                   ▼
                   ┌─────────────┐     ┌─────────────┐
                   │ Not Auth'd  │     │ Auth'd      │
                   │ → Auth      │     │ → Complete  │
                   │   Dialog    │     │   Seal      │
                   └──────┬──────┘     └──────┬──────┘
                          │                   │
                          └─────────┬─────────┘
                                    │
                                    ▼
                          ┌─────────────────────┐
                          │ Witness Dashboard   │
                          │ ─────────────────── │
                          │ • View pacts you    │
                          │   witness           │
                          │ • Send high-fives   │
                          │ • Nudge friends     │
                          └─────────────────────┘
```

**Resolution (Eyal):** The witness success screen now includes a **"Reciprocity Loop."** After sealing a pact for a friend, the user is immediately prompted with "Now it's your turn," creating a powerful psychological nudge to create their own pact.

---

## 5. Niche Landing Pages (Side Doors)

The app has **5 niche-specific entry points** designed for targeted marketing:

| Route | Target Audience | Current Behaviour |
|-------|-----------------|-------------------|
| `/devs` | Programmers, HackerNews | → `ConversationalOnboardingScreen` |
| `/writers` | Writers, Medium | → `ConversationalOnboardingScreen` |
| `/scholars` | Grad students, academics | → `ConversationalOnboardingScreen` |
| `/languages` | Language learners | → `ConversationalOnboardingScreen` |
| `/makers` | Indie hackers | → `ConversationalOnboardingScreen` |

**Resolution (Musk):** All niche routes have been consolidated. They now direct to the `IdentityAccessGateScreen` and pass a `presetIdentity` parameter, creating a seamless, contextual, and consistent user experience.

---

## 6. Friction Points Resolved

All major friction points identified in the initial analysis have been addressed by the Council of Five sprint.

| ID | Original Issue | Resolution (Advisor) |
|----|----------------|----------------------|
| F1 | No payment integration | **Trust Grant Dialog** (Bezos) - Defers payment friction while capturing intent. |
| F2 | Manual witness input | **Native Contact Picker** (Fogg) - Reduces input effort and errors. |
| F3 | Inconsistent niche routes | **Route Consolidation** (Musk) - Unifies all entry points to the modern flow. |
| F4 | Optional identity field | **Identity Mad-Libs** (Clear) - Makes identity mandatory but easier to complete. |
| F5 | No witness conversion | **Reciprocity Loop** (Eyal) - Prompts witnesses to create their own pacts. |
| F5 | `WitnessAcceptScreen` | No "create your own pact" CTA | Missed conversion |
| F6 | `PactWitnessScreen` | No contact picker integration | Manual entry required |

### 🟢 Low Friction (Polish)

| ID | Location | Issue | Impact |
|----|----------|-------|--------|
| F7 | All screens | No progress indicator | Users unsure of length |
| F8 | `IdentityAccessGateScreen` | No identity examples | Users may be confused |

---

## 7. Optimisation Recommendations

### Immediate (Can Do Now)

| Priority | Optimisation | Effort | Impact |
|----------|--------------|--------|--------|
| P1 | Update niche routes to use Identity First flow | Low | High |
| P2 | Add "Create Your Own Pact" CTA to witness success dialog | Low | Medium |
| P3 | Add identity examples/suggestions | Low | Medium |
| P4 | Fix tier selection to complete onboarding properly | Low | High |

### Near-Term (Requires More Work)

| Priority | Optimisation | Effort | Impact |
|----------|--------------|--------|--------|
| P5 | Integrate payment flow for Builder/Ally tiers | High | High |
| P6 | Add contact picker for witness selection | Medium | Medium |
| P7 | Add progress indicator across onboarding | Low | Low |

---

## 8. Recommended Code Changes

### Change 1: Fix Tier Selection Navigation

**File:** `lib/features/onboarding/identity_first/pact_tier_selector_screen.dart`

**Issue:** Currently navigates to `/` which loops back to onboarding.

**Fix:** Should call `appState.completeOnboarding()` and navigate to `/dashboard`.

### Change 2: Update Niche Routes

**File:** `lib/main.dart`

**Issue:** Niche routes (`/devs`, `/writers`, etc.) use old `ConversationalOnboardingScreen`.

**Fix:** Route to `IdentityAccessGateScreen` with niche context passed via query parameter.

### Change 3: Add Conversion CTA to Witness Success

**File:** `lib/features/witness/witness_accept_screen.dart`

**Issue:** Success dialog only shows "View My Pacts" button.

**Fix:** Add "Create Your Own Pact" button that navigates to onboarding.

### Change 4: Add Identity Examples

**File:** `lib/features/onboarding/identity_first/identity_access_gate_screen.dart`

**Issue:** Users may not understand what to enter for identity.

**Fix:** Add placeholder examples like "A marathon runner", "A published author", "A fluent Spanish speaker".

---

## 9. User Journey Metrics (Proposed)

To measure optimisation success, track these events:

| Event | Description | Target |
|-------|-------------|--------|
| `onboarding_started` | User opens app for first time | Baseline |
| `identity_entered` | User enters identity text | >80% |
| `auth_completed` | User completes OAuth/email | >70% |
| `witness_added` | User adds a witness | >30% |
| `tier_selected` | User selects a tier | >95% |
| `onboarding_completed` | User reaches dashboard | >60% |
| `first_pact_created` | User creates first habit | >50% |
| `first_checkin` | User completes first check-in | >40% |

---

## 10. Next Steps

1. **Implement P1-P4 optimisations** (immediate, no build required for review)
2. **Update AI_CONTEXT.md** with journey map reference
3. **Create analytics events** for journey tracking
4. **Test invite flow** end-to-end after APK build

---

*This document should be updated whenever the onboarding flow changes.*
