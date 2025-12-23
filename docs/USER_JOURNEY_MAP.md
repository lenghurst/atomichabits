# User Journey Map — The Pact

> **Last Updated:** 23 December 2025  
> **Author:** Manus AI (Acting Head of Architecture)  
> **Status:** Analysis Complete, Optimisations Identified

---

## Executive Summary

This document maps the complete new user journey for **The Pact**, identifying all entry points, decision nodes, and friction points. The analysis reveals **7 critical optimisation opportunities** that can reduce time-to-value and increase conversion rates.

---

## 1. User Entry Points (Acquisition Channels)

The Pact has **6 distinct entry points**, each with different user intent and context:

| Entry Point | Route | User Intent | Current State |
|-------------|-------|-------------|---------------|
| **Organic Install** | `/` → `IdentityAccessGateScreen` | Curious, exploring | ✅ Working |
| **Invite Deep Link** | `/witness/accept/:code` | High intent, social proof | ✅ Working |
| **Install Referrer** | Play Store → `/witness/accept/:code` | High intent, deferred | ✅ Working |
| **Niche Landing** | `/devs`, `/writers`, `/scholars`, etc. | Targeted, niche-specific | ⚠️ Routes to old chat UI |
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
    │  • Identity declaration │    │  • Skip to Witness      │
    │  • Google OAuth         │    │    Accept Screen        │
    │  • Apple OAuth          │    │  • Show contract first  │
    │  • Email fallback       │    │  • Auth AFTER viewing   │
    │  • DEV mode toggle      │    │                         │
    └──────────┬──────────────┘    └──────────┬──────────────┘
               │                              │
               ▼                              ▼
    ┌─────────────────────────┐    ┌─────────────────────────┐
    │  SCREEN 2: Pact Witness │    │  Witness Accept Screen  │
    │  ────────────────────   │    │  ────────────────────   │
    │  • View commitment      │    │  • View friend's pact   │
    │  • Add witness (opt)    │    │  • Tap-hold to sign     │
    │  • Start solo (opt)     │    │  • Wax seal ceremony    │
    └──────────┬──────────────┘    └──────────┬──────────────┘
               │                              │
               ▼                              ▼
    ┌─────────────────────────┐    ┌─────────────────────────┐
    │  SCREEN 3: Tier Select  │    │  Auth Required Dialog   │
    │  ────────────────────   │    │  ────────────────────   │
    │  • Free ($0)            │    │  • "Sign in to seal"    │
    │  • Builder ($12/mo)     │    │  • Google/Apple OAuth   │
    │  • Ally ($24/mo)        │    │  • Then complete seal   │
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

**Optimisation Opportunity #1:** The identity field is optional but critical for personalisation. Consider making it required or providing examples.

---

### Decision Point 2: Witness Selection
**Location:** `PactWitnessScreen`  
**Question:** "Add a witness or start solo?"

| User Action | Outcome | Friction Level |
|-------------|---------|----------------|
| Adds witness (email/phone) | Invite sent, proceeds | 🟡 Medium |
| Starts solo | Proceeds without witness | 🟢 Low |
| Abandons | Lost user | 🔴 Critical |

**Optimisation Opportunity #2:** The witness input is currently just a text field with no validation. Should integrate with contacts or provide a shareable link.

---

### Decision Point 3: Tier Selection
**Location:** `PactTierSelectorScreen`  
**Question:** "Choose your tools"

| User Action | Outcome | Friction Level |
|-------------|---------|----------------|
| Selects Free | Proceeds to dashboard | 🟢 Low |
| Selects Builder | Should trigger payment flow | ⚠️ Not implemented |
| Selects Ally | Should trigger payment flow | ⚠️ Not implemented |

**Optimisation Opportunity #3:** The tier selection currently just navigates to `/` regardless of selection. No payment integration exists.

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

**Optimisation Opportunity #4:** Invited users who complete the witness flow are not prompted to create their own pact. This is a missed conversion opportunity.

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

**Optimisation Opportunity #5:** These routes bypass the new "Identity First" flow and go directly to the old chat-based onboarding. They should be updated to use the new flow with niche-specific context.

---

## 6. Friction Points Identified

### 🔴 Critical Friction

| ID | Location | Issue | Impact |
|----|----------|-------|--------|
| F1 | `PactTierSelectorScreen` | No payment integration | Users cannot upgrade |
| F2 | `PactWitnessScreen` | Witness input has no validation | Invites may fail |
| F3 | Niche routes | Bypass new onboarding flow | Inconsistent UX |

### 🟡 Medium Friction

| ID | Location | Issue | Impact |
|----|----------|-------|--------|
| F4 | `IdentityAccessGateScreen` | Identity field is optional | Lost personalisation |
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
