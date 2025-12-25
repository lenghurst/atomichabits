# ROADMAP.md — The Pact

> **Last Updated:** 25 December 2025  
> **Current Phase:** Phase 41 - Navigation Architecture  
> **Target:** NYE 2025 Launch  
> **Status:** 🔧 Testing Voice Connection

---

## ⚠️ AI HANDOFF PROTOCOL

### Before Starting Work
1. Read `README.md` for project overview
2. Read `AI_CONTEXT.md` for current architecture
3. Read this file for priorities and history
4. Check `CHANGELOG.md` for recent changes

### After Completing Work
1. Update the relevant section below
2. Add to Sprint History with date
3. Update `AI_CONTEXT.md` if architecture changed
4. Commit and push all changes

---

## 🎯 Current Focus: Voice Connection Testing

**Goal:** Verify the Gemini Live WebSocket connection works after Phases 35-38 fixes.

**Status:** 🔧 Testing

**Verification Steps:**
1. Build app with latest code
2. Open DevTools → Enable Premium Mode
3. Navigate to Voice Coach
4. Tap microphone to connect
5. Check logs via "View Gemini Logs"
6. Analyze result (success, different error, or still 403)

**See:** `docs/VERIFICATION_CHECKLIST.md`

---

## ✅ Completed Phases

### Phase 41: Navigation Architecture (25 Dec 2025)

**Goal:** Extract router from main.dart, add route constants, implement redirect logic.

| ID | Task | Status |
|----|------|--------|
| N1 | Create `AppRoutes` constants class | ✅ |
| N2 | Extract `AppRouter` from main.dart | ✅ |
| N3 | Add redirect logic for auth/onboarding guards | ✅ |
| N4 | Update screens to use route constants | ✅ |
| N5 | Update core documentation | ✅ |

**Files Changed:**
- `lib/config/router/app_routes.dart` (NEW)
- `lib/config/router/app_router.dart` (NEW)
- `lib/main.dart` (reduced by ~180 lines)
- `lib/features/dashboard/habit_list_screen.dart`
- `lib/features/dev/dev_tools_overlay.dart`

### Phase 40: DeepSeek Optimization (25 Dec 2025)

**Goal:** Improve DeepSeek response quality by forcing JSON output.

| ID | Task | Status |
|----|------|--------|
| D1 | Add `response_format: json_object` to API request | ✅ |
| D2 | Update system prompt with JSON output format | ✅ |
| D3 | Verify `.vscode/launch.json` has secrets config | ✅ |

**Files Changed:**
- `lib/data/services/ai/deep_seek_service.dart`

### Phase 39: Logging Consolidation & Security (25 Dec 2025)

**Goal:** Unify logging systems and remove security backdoor.

| ID | Task | Status |
|----|------|--------|
| S1 | Remove Oliver Backdoor from app_state.dart | ✅ |
| S2 | Remove Oliver Backdoor from user_provider.dart | ✅ |
| L1 | Enhance AppLogger with LogBuffer integration | ✅ |
| L2 | Migrate GeminiLiveService to AppLogger | ✅ |
| L3 | Migrate identity_access_gate_screen to AppLogger | ✅ |
| L4 | Delete deprecated developer_logger.dart | ✅ |
| L5 | Update DebugConsoleView for LogEntry structure | ✅ |

**Files Changed:**
- `lib/data/app_state.dart` (backdoor removed)
- `lib/data/providers/user_provider.dart` (backdoor removed)
- `lib/core/logging/app_logger.dart` (enhanced)
- `lib/core/logging/log_buffer.dart` (LogEntry structure)
- `lib/features/dev/debug_console_view.dart` (level-based coloring)
- `lib/utils/developer_logger.dart` (DELETED)

### Phase 38: In-App Log Console (25 Dec 2025)

**Goal:** Provide full visibility into Gemini Live connection for debugging.

| ID | Task | Status |
|----|------|--------|
| L1 | Create LogBuffer singleton | ✅ |
| L2 | Integrate LogBuffer into GeminiLiveService | ✅ |
| L3 | Create DebugConsoleView widget | ✅ |
| L4 | Add "View Gemini Logs" to DevToolsOverlay | ✅ |
| L5 | Verbose connection logging with emojis | ✅ |

**Files Created:**
- `lib/core/logging/log_buffer.dart`
- `lib/features/dev/debug_console_view.dart`
- `docs/PHASE_38_LOG_CONSOLE.md`

### Phase 37: Production-Ready Connection (25 Dec 2025)

**Goal:** Implement honest headers and granular error handling.

| ID | Task | Status |
|----|------|--------|
| H1 | Honest User-Agent header | ✅ |
| H2 | `await _channel!.ready` for handshake | ✅ |
| H3 | HandshakeException handling | ✅ |
| H4 | SocketException handling | ✅ |
| H5 | URL validation asserts | ✅ |

### Phase 36: Header Injection Fix (25 Dec 2025)

**Goal:** Fix 403 Forbidden by adding custom WebSocket headers.

| ID | Task | Status |
|----|------|--------|
| F1 | Switch to IOWebSocketChannel | ✅ |
| F2 | Add Host header | ✅ |
| F3 | Add User-Agent header | ✅ |
| F4 | 5 Whys analysis document | ✅ |

### Phase 35: thinkingConfig Fix (25 Dec 2025)

**Goal:** Fix "Unknown name 'thinkingConfig'" error.

| ID | Task | Status |
|----|------|--------|
| T1 | Move thinkingConfig inside generationConfig | ✅ |
| T2 | Research official API documentation | ✅ |
| T3 | Update setup payload structure | ✅ |

### Phase 34: Architecture Refactoring (Dec 2025)

**Goal:** Implement comprehensive architectural improvements.

| ID | Task | Status |
|----|------|--------|
| A1 | Repository Pattern | ✅ |
| A2 | Domain-specific Providers | ✅ |
| A3 | PsychometricProfile entity | ✅ |
| A4 | PsychometricEngine service | ✅ |
| A5 | Bitmask Risk Flags | ✅ |
| A6 | Migration Documentation | ✅ |

### Phase 33: The Investment (Dec 2025)

**Goal:** Redesign Supporter Screen with modal UI.

| ID | Task | Status |
|----|------|--------|
| I1 | TypeAhead contact search | ✅ |
| I2 | Permission Glass Pane | ✅ |
| I3 | Investment Screen | ✅ |

### Phase 32: Audio Recording (Dec 2025)

**Goal:** Implement audio recording and session management.

| ID | Task | Status |
|----|------|--------|
| R1 | AudioRecordingService | ✅ |
| R2 | VoiceSessionManager | ✅ |
| R3 | VAD integration | ✅ |

### Phases 29-31: Council Recommendations (Dec 2025)

Implemented recommendations from the "Second Council of Five":
- Hook Screen with value proposition
- Graceful Consistency messaging
- Confetti celebration
- Testimonials
- Binary tier choice
- Default identity selection
- Haptic feedback

---

## 📋 Backlog

### Phase 41: Provider Wiring (Post-Launch)

**Goal:** Wire new providers into main.dart.

**Priority:** HIGH

| ID | Task | Effort | Status |
|----|------|--------|--------|
| W1 | Parallel repository initialisation | Low | [ ] |
| W2 | ProxyProvider for User → Habit | Medium | [ ] |
| W3 | Integrate PsychometricProvider | Medium | [ ] |
| W4 | Update GoRouter to use UserProvider | Low | [ ] |

### Phase 42: DTO Separation (Q1 2026)

**Goal:** Separate domain entities from persistence.

**Priority:** MEDIUM

| ID | Task | Effort | Status |
|----|------|--------|--------|
| D1 | Create HabitDTO | Medium | [ ] |
| D2 | Create UserProfileDTO | Medium | [ ] |
| D3 | Remove toJson from entities | Low | [ ] |
| D4 | Create Mapper classes | Medium | [ ] |

### Phase 43: HabitEngine Extraction (Q1 2026)

**Goal:** Extract business logic from AppState.

**Priority:** MEDIUM

| ID | Task | Effort | Status |
|----|------|--------|--------|
| H1 | Create HabitEngine service | High | [ ] |
| H2 | Extract streak calculation | Medium | [ ] |
| H3 | Extract recovery logic | Medium | [ ] |

### Post-Launch Features (Phase 44+)

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
| TD1 | AppState monolithic (1,642 lines) | Medium | Phase 39-41 |
| TD2 | Habit.dart has toJson | Low | Phase 40 |
| TD3 | No DTO separation | Low | Phase 40 |
| TD4 | HabitEngine in AppState | Medium | Phase 41 |
| TD5 | landing_page/ in Flutter repo | Low | Future |

~~TD0 resolved in Phase 39~~ - Oliver Backdoor removed from both `app_state.dart` and `user_provider.dart`.

---

## 📊 Architecture Evolution

```
Phase 33          Phase 34          Phase 35-38       Phase 39+
    │                 │                 │                 │
    ▼                 ▼                 ▼                 ▼
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│Monolithic│  →  │Repository│  →  │Voice Fix│  →  │Provider │
│AppState  │     │Pattern   │     │+ Logging│     │Wiring   │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
```

---

## 🎯 Success Metrics

### Launch (NYE 2025)

| Metric | Target | Status |
|--------|--------|--------|
| APK builds | ✅ | ✅ |
| Voice connects | < 500ms latency | 🔧 Testing |
| No crashes on Xiaomi | 0 crashes | [ ] |
| Share Sheet works | Functional | [ ] |
| Voice Coach accessible | From Dashboard | ✅ |

### Post-Launch (Q1 2026)

| Metric | Target | Status |
|--------|--------|--------|
| Unit test coverage | > 60% | [ ] |
| AppState deprecated | 100% | [ ] |
| Domain entities pure | 100% | [ ] |

---

## 📁 Documentation Structure

### Core (Root Level)
- `README.md` - Project overview
- `AI_CONTEXT.md` - AI assistant context
- `ROADMAP.md` - This file
- `CHANGELOG.md` - Version history
- `CREDITS.md` - Attribution

### Technical (docs/)
- `docs/BUILD_PIPELINE.md` - Build commands
- `docs/VERIFICATION_CHECKLIST.md` - Testing protocol
- `docs/GOOGLE_OAUTH_SETUP.md` - OAuth setup
- `docs/ARCHITECTURE_MIGRATION.md` - Provider guide

### Gemini Live (docs/)
- `docs/PHASE_38_LOG_CONSOLE.md`
- `docs/PHASE_37_PRODUCTION_READY.md`
- `docs/PHASE_36_ERROR_ANALYSIS.md`
- `docs/GEMINI_LIVE_API_RESEARCH.md`
- `docs/GEMINI_WEBSOCKET_SCHEMA.md`

### Archive (docs/archive/)
- Legacy implementation summaries
- Old phase specs
