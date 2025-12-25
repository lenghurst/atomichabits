# ROADMAP.md — The Pact

> **Last Updated:** 25 December 2025  
> **Current Phase:** Phase 42 - Soul Capture Onboarding  
> **Target:** NYE 2025 Launch  
> **Status:** ✅ Sherlock Protocol **IMPLEMENTED**. Real-time tool calling working.

---

## 🎯 Current Focus: Soul Capture Onboarding (Phase 42)

**Goal:** Implement AI-powered psychological profiling during onboarding using the Sherlock Protocol.

**Status:** ✅ **COMPLETE**. Real-time tool calling integrated with Gemini Live API.

**What Was Built:**
1. **Tool Schema:** `ai_tools_config.dart` - Function declaration for `update_user_psychometrics`
2. **Sherlock Protocol Prompt:** `ai_prompts.dart` - Conversation flow that deduces traits
3. **Tool Call Handler:** `gemini_live_service.dart` - Parses tool_call events, sends responses
4. **Session Orchestration:** `voice_session_manager.dart` - Routes tool calls to provider
5. **Profile Updates:** `psychometric_provider.dart` - `updateFromToolCall()` with immediate Hive save
6. **Dynamic Prompts:** `prompt_factory.dart` - Injects Holy Trinity into subsequent sessions

**Immediate Priorities:**
1.  **Test on Device:** Verify Sherlock Protocol conversation flow on physical device
2.  **Fix Unit Tests:** Resolve the 5 failing unit tests in `date_utils_test.dart`
3.  **Static Analysis:** Clean up the 154 static analysis issues (mostly unused imports)
4.  **GitHub Actions:** Guide the user to set up the 6 required repository secrets for the build workflow

---

## ✅ Completed Phases

### Phase 42: Soul Capture Onboarding (25 Dec 2025)

**Goal:** Implement the Sherlock Protocol for psychological profiling with real-time tool calling.

| ID | Task | Status |
|----|------|--------|
| S1 | Create `ai_tools_config.dart` with tool schema | ✅ |
| S2 | Add `voiceOnboardingSystemPrompt` (Sherlock Protocol) | ✅ |
| S3 | Add Holy Trinity fields to `PsychometricProfile` | ✅ |
| S4 | Add `updateFromToolCall()` to `PsychometricProvider` | ✅ |
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

### Phase 43: Pre-Launch Fixes (High Priority)

**Goal:** Address all remaining blockers before the first device test build.

| ID | Task | Effort | Status |
|----|------|--------|--------|
| T1 | Fix 5 failing unit tests | Low | [ ] |
| T2 | Fix 154 static analysis issues | Low | [ ] |
| G1 | Guide user to add GitHub Actions secrets | Low | [ ] |
| G2 | Commit and push GitHub Actions workflow file | Low | [ ] |

### Phase 44: Provider Wiring (Post-Launch)

**Goal:** Wire new providers into `main.dart` to continue strangling the legacy `AppState`.

| ID | Task | Effort | Status |
|----|------|--------|--------|
| W1 | Parallel repository initialisation | Low | [ ] |
| W2 | ProxyProvider for User → Habit | Medium | [ ] |
| W3 | Integrate PsychometricProvider | Medium | [ ] |
| W4 | Update GoRouter to use UserProvider | Low | [ ] |

### Phase 44: DTO Separation (Q1 2026)

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
