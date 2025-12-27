# ROADMAP.md — The Pact

> **Last Updated:** 26 December 2025  
> **Current Phase:** Phase 46.5 - Release Preparation (Voice 2.0)
> **Target:** NYE 2025 Launch  
> **Status:** ✅ Voice Architecture Simplified (StreamVoicePlayer)

---

## 🎯 Current Focus: Pre-Launch Fixes (Phase 45)

**Goal:** Address critical blockers (tests, static analysis, build pipeline) before the first device test build and fix data fragmentation issues.

**Status:** ✅ **COMPLETE**. Critical blockers and data fragmentation resolved.
 
**What Was Built (Phase 45):**
1. **User Data Unification:** Migrated `isPremium` from standalone Hive key to `UserProfile` model
2. **Cloud Sync Preparation:** Added `isSynced` and `lastUpdated` to `PsychometricProfile`
3. **Migration Engine:** Automatic legacy data migration for User data on app launch
4. **Verification Tests:** Unit tests for both User migration and Psychometric sync logic

**Immediate Priorities:**
1.  **Test on Device:** Verify complete onboarding → reveal → dashboard flow
2.  **Fix Unit Tests:** Resolve the 5 failing unit tests in `date_utils_test.dart`
3.  **Static Analysis:** Clean up the 154 static analysis issues (mostly unused imports)
4.  **GitHub Actions:** Guide the user to set up the 6 required repository secrets

---

## ✅ Completed Phases

### Phase 46.5: Voice 2.0 (27 Dec 2025)
**Goal:** Simplify voice architecture and fix audio reliability issues.

| ID | Task | Status |
|----|------|--------|
| V1 | Create `StreamVoicePlayer` service | ✅ |
| V2 | Migrate `VoiceSessionManager` to use Stream V2 | ✅ |
| V3 | Refactor `VoiceCoachScreen` (Ui logic only) | ✅ |
| V4 | Refactor `SherlockScreen` (Ui logic only) | ✅ |
| V5 | Fix "Forced Data Wipe" bug in `AppState` | ✅ |
| V6 | Adaptive VAD (DC Removal + Dynamic Noise Floor) | ✅ |
| V7 | UI Interruption Handling (User Priority) | ✅ |
| V8 | Manual Turn-Taking (Tap-to-Talk) Implementation | ✅ |


### Phase 44: The Investment (26 Dec 2025)

**Goal:** Lock the user's identity by persisting PsychometricProfile and completing onboarding (Nir Eyal's Hook Model - Investment).

| ID | Task | Status |
|----|------|--------|
| I1 | Add `finalizeOnboarding()` to `PsychometricProvider` | ✅ |
| I2 | Wire "ENTER THE PACT" CTA to persist profile | ✅ |
| I3 | Call `UserProvider.completeOnboarding()` | ✅ |
| I4 | Call `AppState.completeOnboarding()` for router guard | ✅ |
| I5 | Heavy haptic on identity commit | ✅ |
| I6 | Unify `isPremium` into `UserProfile` (Hive Migration) | ✅ |

**Why This Matters:**
- User has invested time + psychological insight → stored value → higher retention
- The persisted profile enables personalised coaching in future sessions
- Completing onboarding unlocks the main app dashboard

### Phase 43: The Variable Reward (25 Dec 2025)

**Goal:** Visualise the Soul Capture data as a premium digital artifact (Nir Eyal's Hook Model).

| ID | Task | Status |
|----|------|--------|
| V1 | Create `psychometric_profile_extensions.dart` | ✅ |
| V2 | Create `pact_identity_card.dart` (3D flip animation) | ✅ |
| V3 | Create `pact_reveal_screen.dart` (loading → reveal) | ✅ |
| V4 | Add `pactReveal` route to `app_routes.dart` | ✅ |
| V5 | Wire `PactRevealScreen` in `app_router.dart` | ✅ |
| V6 | Add "DONE" button + navigation in `voice_coach_screen.dart` | ✅ |

**Visual Design:**
- Front: "THE PACT" fingerprint + "TAP TO REVEAL"
- Back: "I AM BECOMING..." / "I AM BURYING [strikethrough]" / "OPERATING RULE #1"
- Dynamic archetype colours (Gold, Purple, Red, Blue, Orange)

### Phase 42: Soul Capture Onboarding (25 Dec 2025)

**Goal:** Implement the Sherlock Protocol for psychological profiling with real-time tool calling.

| ID | Task | Status |
|----|------|--------|
| S1 | Create `ai_tools_config.dart` with tool schema | ✅ |
| S2 | Add `voiceOnboardingSystemPrompt` (Sherlock Protocol) | ✅ |
| S3 | Add Holy Trinity fields to `OnboardingData` & `PsychometricProfile` | ✅ |
| S4 | Add `updateFromToolCall()` & `updateFromOnboardingData()` | ✅ |
| S5 | Create `prompt_factory.dart` for dynamic prompts | ✅ |
| S6 | Add tool calling support to `GeminiLiveService` | ✅ |
| S7 | Add session modes to `VoiceSessionManager` | ✅ |

**Key Innovation (Council of Five):**
- **Steve Jobs:** Replace cognitive homework with nickname assignment
- **Daniel Kahneman:** Sherlock Protocol (infer traits, don't ask for self-diagnosis)
- **Margaret Hamilton:** Save each trait immediately (crash recovery)
- **Nir Eyal:** Holy Trinity maps to retention funnel (Day 1, Day 7, Day 30+)

### Phase 41.3: Documentation Overhaul (25 Dec 2025)

**Goal:** Bring all core documentation up to date with the latest project status, architectural changes, and API research findings.

| ID | Task | Status |
|----|------|--------|
| D1 | Extensively update `README.md` | ✅ |
| D2 | Extensively update `AI_CONTEXT.md` | ✅ |
| D3 | Extensively update `ROADMAP.md` | ✅ |

### Phase 41.2: Navigation Migration Complete (25 Dec 2025)

**Goal:** Migrate all 44 string literal navigation calls to type-safe `AppRoutes` constants.

- **Total calls migrated:** 44
- **Files updated:** 19
- **Bugs fixed:** 4 (invalid routes, wrong API)
- **String literals remaining:** 0

### Phase 40: DeepSeek Optimization (25 Dec 2025)

**Goal:** Improve DeepSeek response quality by forcing JSON output.

### Phase 39: Logging Consolidation & Security (25 Dec 2025)

**Goal:** Unify logging systems and remove the "Oliver" security backdoor.

### Phase 38: In-App Log Console (25 Dec 2025)

**Goal:** Provide full visibility into the Gemini Live connection for debugging.

### Phase 37: Production-Ready Connection (25 Dec 2025)

**Goal:** Implement honest headers and granular error handling for the WebSocket connection.

### Phase 36: Header Injection Fix (25 Dec 2025)

**Goal:** Fix 403 Forbidden error by adding custom WebSocket headers using `IOWebSocketChannel`.

### Phase 35: `thinkingConfig` Fix (25 Dec 2025)

**Goal:** Fix "Unknown name 'thinkingConfig'" error by correcting the API payload structure.

---

## 📋 Backlog


### Phase 45: Pre-Launch Fixes (High Priority)

**Goal:** Address all remaining blockers before the first device test build.

| ID | Task | Effort | Status |
|----|------|--------|--------|
| T1 | Fix 5 failing unit tests | Low | [x] |
| T2 | Fix static analysis issues (withOpacity) | Low | ✅ |
| F1 | Fix onboarding route gap (PactRevealScreen) | Low | ✅ |
| F2 | Integrate Sherlock Profiling for Text Chat | Low | ✅ |
| F3 | - [x] Fix Voice Silence (Gemini Config)<br>- [x] Implement Universal JSON Parser (Audio) | Low | ✅ |
| F4 | Fix Google Sign-In Bypass (Identity Gate Loop) | Low | ✅ |
| F4 | Fix Factory Reset (Added Supabase SignOut) | Low | ✅ |
| A1 | Perform Engineering Audit & Remediation | Low | ✅ |
| G1 | Guide user to add GitHub Actions secrets | Low | [ ] |
| G2 | Commit and push GitHub Actions workflow file | Low | [ ] |

### Phase 46.1: Security & Clean Code (Technical Debt Remediation)

**Goal:** Secure API keys and remove deprecated code paths before release.

| ID | Task | Effort | Status |
|----|------|--------|--------|
| S1 | Create `Env` class for secure configuration | Low | [x] |
| S2 | Remove hardcoded keys in `GeminiChatService` | Low | [x] |
| S3 | Inject endpoints in `AiSuggestionService` | Low | [x] |
| S4 | Remove legacy "Backdoor" comments | Low | [x] |


### Phase 46: Provider Wiring (Post-Launch)

**Goal:** Wire new providers into `main.dart` to continue strangling the legacy `AppState`.

| ID | Task | Effort | Status |
|----|------|--------|--------|
| W1 | Parallel repository initialisation | Low | [ ] |
| W2 | ProxyProvider for User → Habit | Medium | [ ] |
| W3 | Integrate PsychometricProvider | Medium | [ ] |
| W4 | Update GoRouter to use UserProvider | Low | [ ] |

### Phase 47: DTO Separation (Q1 2026)

**Goal:** Separate domain entities from persistence logic by introducing Data Transfer Objects (DTOs).

| ID | Task | Effort | Status |
|----|------|--------|--------|
| D1 | Create HabitDTO | Medium | [ ] |
| D2 | Create UserProfileDTO | Medium | [ ] |
| D3 | Remove `toJson` from entities | Low | [ ] |
| D4 | Create Mapper classes | Medium | [ ] |

### Post-Launch Features (Phase 45+)

| ID | Feature | Priority | Status |
|----|---------|----------|--------|
| F1 | Push Notifications for Witness | High | [ ] |
| F2 | Deep Link handling | High | [ ] |
| F3 | Voice Coach "Daily Standup" | Medium | [ ] |
| F4 | Apple Sign-In | Medium | [ ] |
| F5 | Offline-first sync | Low | [ ] |

---

## 🧠 Technical Debt Register

| ID | Description | Priority | Target |
|----|-------------|----------|--------|
| ~~TD0~~ | ~~Oliver Backdoor~~ | ~~CRITICAL~~ | ✅ Phase 39 |
| TD1 | `AppState` monolithic (1,642 lines) | Medium | Phase 43+ |
| TD2 | `Habit.dart` has `toJson` | Low | Phase 44 |
| TD3 | No DTO separation | Low | Phase 44 |
| TD4 | `HabitEngine` logic in `AppState` | Medium | Future |
| TD5 | `landing_page/` in Flutter repo | Low | Future |

---

## 🚀 Launch Plan

### Success Metrics (NYE 2025 Launch)

| Metric | Target | Status |
|--------|--------|--------|
| **APK builds via GitHub Actions** | ✅ **Builds successfully** | [ ] |
| **Voice connects on device** | < 500ms latency | [ ] |
| No crashes on user's device | 0 crashes | [ ] |
| Share Sheet works | Functional | [ ] |
| Voice Coach accessible | From Dashboard | ✅ |

### Post-Launch Goals (Q1 2026)

| Metric | Target | Status |
|--------|--------|--------|
| Unit test coverage | > 60% | [ ] |
| `AppState` deprecated | 100% | [ ] |
| Domain entities are pure | 100% | [ ] |
