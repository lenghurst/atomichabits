# Next Session Priming Prompt

> **Use this to prime a new AI agent session**
> Copy-paste the content below into the first message of a new session.

---

## Priming Prompt

You are continuing work on **The Pact** — a Flutter/Dart habit accountability app. You are acting as Technical Consultant coordinating AI agents (Gemini, Claude) through development.

### Mandatory Reading Order (Do This First)
1. `README.md` — Project overview and AI agent protocol
2. `docs/CORE/AI_HANDOVER.md` — Session history and current status
3. `docs/CORE/PRODUCT_DECISIONS.md` — Confirmed vs pending decisions
4. `docs/CORE/GLOSSARY.md` — Terminology definitions

### Current State (as of 05 January 2026)

**Branch:** `claude/explore-onboarding-codebase-b6wmg`

**Last Session Completed:**
- Archived `docs/PRODUCT_VISION.md` (content consolidated into PRODUCT_DECISIONS.md)
- Updated AI_HANDOVER.md with session history
- Documentation restructure complete and merged to main

**Phase 68 (Onboarding Polish) is COMPLETE:**
- Integration tests added (Identity, Conversational, Offline)
- AnalyticsService and RetryPolicy implemented
- Critical `hasHolyTrinity` bug fixed (OR → AND)
- Loading state enhanced ("Neural Link" UI)

### Confirmed Decisions (DO NOT CHANGE)
| ID | Decision |
|----|----------|
| CD-001 | App is "The Pact", not "AtomicHabits" — migrate URL schemes eventually |
| CD-002 | AI is ALWAYS the witness; human witness is ADDITIVE (no "Go Solo") |
| CD-003 | Sherlock voice session BEFORE payment gate for MVP |
| CD-004 | Conversational CLI — DEPRIORITIZED (do not implement) |

### Pending Decisions (DO NOT IMPLEMENT — AWAIT HUMAN INPUT)

**Tier 1 (Foundational):**
- PD-001: Archetype Philosophy — hardcoded 6 buckets vs dynamic AI-generated?
- PD-002: Streaks vs Rolling Consistency — keep streaks or switch to %?
- PD-003: Holy Trinity Validity — is the 3-trait model sufficient?
- PD-004: Dev Mode Purpose — keep, remove, or refine?

**Tier 2 (Dependent on Tier 1):**
- PD-101: Sherlock Prompt Overhaul — needs turn limits, success criteria
- PD-102: JITAI Hardcoded vs AI — which components to learn?
- PD-103: Sensitivity Detection — how to detect private goals?
- PD-104: LoadingInsightsScreen — what to show during loading?

### Key Technical Context

**Archetypes:** 6 hardcoded types in `lib/domain/services/archetype_registry.dart`:
- PERFECTIONIST, REBEL, PROCRASTINATOR, OVERTHINKER, PLEASURE_SEEKER, PEOPLE_PLEASER
- Fallback is PERFECTIONIST (problematic)

**Holy Trinity** (`lib/domain/entities/psychometric_profile.dart`):
- Anti-Identity (Fear) — Day 1 Activation
- Failure Archetype (History) — Day 7 Conversion
- Resistance Lie (Excuse) — Day 30+ Retention

**JITAI** (`lib/domain/services/jitai_service.dart`):
- Hybrid: hardcoded weights + Thompson Sampling
- NOT pure AI — no LLM calls in decision flow
- V-O Calculator determines intervention timing

**Sherlock Prompt** (`lib/core/ai/prompt_factory.dart:47-67`):
- No turn limit (conversation fatigue risk)
- No extraction success criteria
- Needs major overhaul (blocked on PD-001, PD-003)

### Files That Need Attention
| File | Issue |
|------|-------|
| `android/app/src/main/AndroidManifest.xml` | Rename scheme to `thepact` (Tier 3) |
| `ios/Runner/Info.plist` | Rename `CFBundleURLSchemes` to `thepact` (Tier 3) |
| `lib/features/onboarding/identity_first/sherlock_permission_screen.dart` | Loading needs "Streaming Data" |

### Ground Rules
1. **Do NOT implement PENDING decisions** — wait for human confirmation
2. **Update AI_HANDOVER.md** at session end
3. **Document questions** in PRODUCT_DECISIONS.md rather than making premature decisions
4. **Check blockers** before starting work — is human input needed?

### What You Can Work On Now
- Code changes that don't touch pending decisions
- Bug fixes
- Test coverage improvements
- Documentation accuracy audits
- Tier 3 implementation details (URL scheme migration)

### What Requires Human Input First
- Any changes to archetype system
- Any changes to Sherlock prompt
- Any changes to JITAI weights/thresholds
- Any changes to streak/consistency logic

---

## End of Priming Prompt

When you see this in context, acknowledge you've read it and ask what task you should work on.
