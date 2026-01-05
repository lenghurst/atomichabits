# ADR 002: Dual Onboarding Flows Strategy

**Date:** 2026-01-05
**Status:** Accepted

## Context
The Atomic Habits app has evolved through two distinct onboarding paradigms:
1. **Conversational Flow (Legacy/Experimental):** A fully chat-based interface where the user talks to an AI (text or voice) to build their profile. This was the original "Sherlock" vision.
2. **Identity-First Flow (Current Standard):** A structured, screen-based flow (Bootstrap -> Identity -> Motivation -> Pact) that integrates specific AI moments (Sherlock v2) as discrete steps.

We currently face a codebase with artifacts from both, leading to potential confusion and maintenance overhead. This ADR clarifies the strategy for managing these coexisting architectures.

## Decision
We have decided to **standardize on the Identity-First Flow as the primary architecture**, while treating "Conversational" elements not as a separate flow, but as **modular components** that can be injected into the structured flow.

The strict "Conversational Flow" (pure chat from start to finish) is deprecated as the default entry point but preserved for:
- A/B testing variations.
- "Coach Mode" interactions post-onboarding.
- Fallback for accessibility or preference.

### Architecture Nuances
- **Data Source of Truth:** `PsychometricProvider` and `OnboardingOrchestrator` are the single sources of truth. Both flows write to these same providers.
- **Routing:** The `AppRouter` defaults to the standard Identity-First route (`/onboarding/bootstrap` -> `/onboarding/identity`).
- **Sherlock Integration:** "Sherlock" is no longer the *entire* onboarding; it is a specific *phase* (The Scan & The Interview) inserted between Permission granting and Pact creation.

## Consequences
### Positive
- **Stability:** The Identity-First flow is deterministic and easier to test (E2E tests P1.1).
- **Control:** We can guarantee users hit critical legal/structural milestones (e.g., Payment, Permissions) which are harder to enforce in a free-form chat.
- **Modularity:** Voice/Chat components are decoupled from the routing logic.

### Negative
- **Code Duplication:** Some logic exists in both `ConversationalOnboardingScreen` and the individual Identity screens.
- **Maintenance:** We must ensure `OnboardingOrchestrator` updates correctly regardless of which UI drives it.

## Implementation Details
- `OnboardingOrchestrator` acts as the Facade.
- `PsychometricProvider` holds the state.
- `SherlockPermissionScreen` acts as the bridge into the "Conversational" module (Sherlock Voice Session) and returns to the structured flow (`PactReveal`) upon completion.
