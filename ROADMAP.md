# ROADMAP.md — The Pact

> **Last Updated:** 30 December 2025  
> **Current Phase:** Phase 62 - Sherlock Protocol Refinement 🧱 = Blocked
- 🔒 = **FROZEN / LOCKED** (Do not change)

## 🔒 LOCKED CONFIGURATIONS (Stable)
- **Reasoning Model:** `gemini-3-flash-preview` (Gemini 3 Flash)
- **TTS Model:** `gemini-2.5-flash-preview-tts` (Flash TTS)
- **Native Audio:** `gemini-2.5-flash-native-audio-preview-12-2025`
> **Target:** NYE 2025 Launch  
> **Status:** ✅ Sherlock Refined (v6.9.6)

---

## 🎯 Current Focus: Navigation Audit (Phase A)

**Goal:** Clean up the navigation stack before full release.

**Status:** 🟡 **IN PROGRESS**
 
**What Was Built (Phase 4 & 7):**
1. **Persistent Navigation:** `StatefulShellRoute` implemented with 3-tab `BottomNavigationBar`.
2. **Strangler Fig:** Onboarding logic successfully decoupled from legacy `AppState`.
3. **Prompt Orchestrator:** Dynamic prompt injection implemented in service layer.

**Immediate Priorities:**
1.  **Analyze Router:** Audit entire `app_router.dart` for legacy paths.
2.  **Verify Device:** Confirm persistent tab state on physical hardware.
3.  **Refine Voice Onboarding:** Tighten up the "Sherlock Screening" flow.

---

## 🚀 Upcoming Priorities

### Phase 61: Data Architecture Audit (Current)
**Goal**: Audit how data is captured, stored, analysed, and leveraged.
**Status**: 🔴 STOP & FIX (Critical Vulnerability Found)

| ID | Task | Status |
|----|------|--------|
| D1 | **Capture Audit**: Review Audio/Sensors/Inputs. | ⏸️ |
| D2 | **Storage Audit**: Review Hive/Supabase/Security. | ⏸️ |
| D3 | **Analysis Audit**: Review AI/Psychometrics. | ⏸️ |
| D4 | **Leverage Audit**: Ensure data serves the user. | ⏸️ |
| D5 | **Nightmare Scenario Protocol**: Week 1 Gate. | 🔴 FAILED |

---

## 🎯 Current Focus: Navigation Audit (Phase A)

## ✅ Completed Phases

### Phase 62: Sherlock Protocol Refinement (30 Dec 2025)
**Goal:** Align Sherlock with IFS therapy principles and fix privacy leaks.

| ID | Task | Status |
|----|------|--------|
| S1 | **IFS Protocol**: Retrain Sherlock as "Parts Detective" (Protector Parts). | ✅ |
| S2 | **Autonomy Gate**: Replace AI approval with User Declaration. | ✅ |
| S3 | **Privacy Fix**: Thread-safe audio cleanup in `VoiceCoachScreen`. | ✅ |
| S4 | **Type Safety**: Fix `Candidate` constructor in `GeminiVoiceNoteService`. | ✅ |

### Phase 4 & 7: Architecture Modernization (28 Dec 2025)
**Goal:** Implement persistent navigation and decouple legacy state logic.

| ID | Task | Status |
|----|------|--------|
| A1 | Implement `StatefulShellRoute` (Bottom Nav) | ✅ |
| A2 | Isolate `OnboardingState` (Strangler Fig) | ✅ |
| A3 | Decouple Prompt Logic to `OnboardingOrchestrator` | ✅ |
| A4 | Harden `AppState` Null Safety | ✅ |


---

### Phase 60: Voice Reliability (Hybrid Stack) (29 Dec 2025)
**Goal:** Fix TTS 400 error and ensure robust audio generation.

| ID | Task | Status |
|----|------|--------|
| H1 | **Hybrid Architecture**: Split Reasoning (SDK) and Mouth (REST). | ✅ |
| H2 | **Gemini 3 Enforcement**: Ensure reasoning uses high-IQ model. | ✅ |
| H3 | **REST TTS**: Bypass SDK limits for `responseModalities: ["AUDIO"]`. | ✅ |
| H4 | **WAV Construction**: Manual PCM-to-WAV wrapping. | ✅ |

### Phase 59: Unified Low-Latency Audio (SoLoud) (29 Dec 2025)
**Goal:** Deliver ultra-low latency (<50ms) voice interaction using C++ FFI.

| ID | Task | Status |
|----|------|--------|
| L1 | **SoLoud Protocol**: Replace `audioplayers` with `flutter_soloud` (FFI). | ✅ |
| L2 | **Direct Streaming**: Implement `addAudioDataStream` for raw PCM. | ✅ |
| L3 | **Safety Fuse**: Retain `flutter_webrtc` as hardware AEC anchor for Android. | ✅ |
| L1 | **SoLoud Protocol**: Replace `audioplayers` with `flutter_soloud` (FFI). | ✅ |
| L2 | **Direct Streaming**: Implement `addAudioDataStream` for raw PCM. | ✅ |
| L3 | **Safety Fuse**: Retain `flutter_webrtc` as hardware AEC anchor for Android. | ✅ |
| L4 | **Buffer Tuning**: Eliminate WAV header injection latency. | ✅ |
| L5 | **Stabilization**: Silence Debouncer & Safety Gates (Phase 59.3). | ✅ |
| L6 | **Unified Source of Truth (Phase 59.4)**: Fixed UI/Audio desync (Amber Lock) by delegating state to StreamVoicePlayer. | ✅ |

### Phase 58: Deferred Intelligence & DeepSeek (29 Dec 2025)
**Goal:** Fix "Reasoning Lock" by moving analysis to post-session DeepSeek pipeline.

| ID | Task | Status |
|----|------|--------|
| D1 | **DeepSeek V3 Integration**: Replace Gemini Flash with DeepSeek-V3 for analysis. | ✅ |
| D2 | **Deferred Architecture**: Buffer transcript in `VoiceSessionManager`. | ✅ |
| D3 | **Analysis Loader**: Add "Sherlock is Analyzing..." state to `VoiceCoachScreen`. | ✅ |
| D4 | **Zero-Dependency**: Use raw `http` for `PsychometricProvider` (No SDK). | ✅ |

### Phase 32.5: Hardware AEC Enforcement (28 Dec 2025)
**Goal:** Fix the "Echo Nightmare" by enforcing OS-level echo cancellation.

| ID | Task | Status |
|----|------|--------|
| A1 | Integrate `flutter_webrtc` for dummy stream | ✅ |
| A2 | Configure `AudioSession` for `videoChat` | ✅ |
| A3 | Refactor `AudioRecordingService` to hybrid stack | ✅ |

### Phase 52: Audio Foundation MVP (28 Dec 2025)
**Goal:** Finalize audio stability for release.

| ID | Task | Status |
|----|------|--------|
| F1 | Enforce Strict Push-to-Talk (No Barge-In) | ✅ |
| F2 | Implement Hardware AEC Lock ("Dummy Stream") | ✅ |
| F3 | Fix Background Audio Ducking (`mixWithOthers`) | ✅ |
| F4 | Fix Gemini Code 1007 (`turnComplete` payload) | ✅ |

### Phase 53: Post-MVP Polish (Q1 2026)
**Goal:** Refine the Sherlock Screening UI based on user feedback.

| ID | Task | Status |
|----|------|--------|
| P1 | **Visual States**: Clearly separate "Speaking", "Listening", "Thinking" states (Color/Anim). | [ ] |
| P2 | **Hold Button**: Improve tactile feedback for PTT hold gesture. | [ ] |
| P3 | **Interrupt UI**: Re-introduce "Tap to Interrupt" if PTT feels too restrictive. | [ ] |

### Phase 50: Gemini API Reconciliation (27 Dec 2025)
**Goal:** Align implementation with official docs and harden audio pipeline.

| ID | Task | Status |
|----|------|--------|
| G1 | Move `outputAudioTranscription` to `generationConfig` | ✅ |
| G2 | Implement robust WAV Header Buffering (Split-chunk support) | ✅ |
| G3 | Remove hazardous `tier2Temperature` | ✅ |

### Phase 49: Sherlock Screening & Reliability (27 Dec 2025)
**Goal:** Fix AI "Amnesia" and formalize the "Sherlock Screening" phase.

| ID | Task | Status |
|----|------|--------|
| R1 | Fix `thoughtSignature` context loss (AI Amnesia) | ✅ |
| R2 | Audit "Thinking Mode" defaults for Gemini 2.5 | ✅ |
| R3 | Rename UI header to "SHERLOCK SCREENING" | ✅ |
| R4 | Verify Always-On VAD stability | ✅ |

### Phase 48: Voice Note Style UI (27 Dec 2025)
**Goal:** Replace "Orb" interaction with intuitive Voice Note controls.

| ID | Task | Status |
|----|------|--------|
| U1 | Separate Visualizer (Orb) from Controls (Button) | ✅ |
| U2 | Implement Hold-to-Talk Logic | ✅ |
| U3 | Implement Tap-to-Lock Logic | ✅ |
| U4 | Explicit State Labels ("Sherlock Speaking", "Tap to Send") | ✅ |

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
