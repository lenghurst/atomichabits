# ROADMAP.md — The Pact

> **Last Updated:** 25 December 2025 (Commit: Phase 34.4 - Gemini Model Fix)  
> **Last Verified:** Phase 34.4 Complete (Gemini Model Fix + Parser Improvements)  
> **Current Focus:** NYE 2025 LAUNCH  
> **Status:** 🟢 COUNCIL APPROVED - Ready for Launch  
> **Council Verdict:** GREEN LIGHT  
> **Language:** UK English (Default)

---

## ⚠️ AI HANDOFF PROTOCOL

### Before Starting Work
1. Read `AI_CONTEXT.md` for current architecture state
2. Read `README.md` for project overview
3. Read `docs/ARCHITECTURE_MIGRATION.md` for new provider architecture
4. Check `lib/config/ai_model_config.dart` (AI endpoints)
5. Check `lib/domain/entities/psychometric_profile.dart` (LLM context)

### After Completing Work
1. Update the relevant section below (move items, add details)
2. Add to Sprint History with date and changes
3. Update `AI_CONTEXT.md` with changes made
4. Commit all changes to `main` branch

---

## 🚀 LAUNCH READY

**Goal:** Final build, test, and launch for NYE 2025.

**Status:** 🟢 COMPLETE - All planned features implemented. Awaiting final smoke test.

**Target:** NYE 2025 Launch

### Phase 34: Architecture Refactoring (The "Council of Five")

**Goal:** Implement comprehensive architectural improvements based on expert review.

**Status:** 🟢 COMPLETE (Phase 34.3)

| ID | Recommendation | Expert | Status |
|----|----------------|--------|--------|
| A1 | Repository Pattern (Dependency Inversion) | Uncle Bob | ✅ |
| A2 | Domain-specific Providers | Rousselet | ✅ |
| A3 | PsychometricProfile (Rich Domain Entity) | Fowler | ✅ |
| A4 | PsychometricEngine (Incremental Updates) | Muratori | ✅ |
| A5 | Bitmask Risk Flags (O(1) checks) | Muratori | ✅ |
| A6 | Migration Documentation | Evans | ✅ |
| A7 | Isolate wrapper for recalibrateRisks | Muratori | ✅ (34.1) |
| A8 | Shadow Wiring in main.dart | Rousselet | ✅ (34.2) |
| A9 | Oliver Backdoor for Tier 2 verification | Council | ✅ (34.3) |
| A10 | Voice Coach button in Dashboard | Council | ✅ (34.4) |
| A11 | In-app API key debug diagnostics | Council | ✅ (34.4) |
| A12 | Gemini model name fix (verified from docs) | Council | ✅ (34.4b) |
| A13 | AI response parser Markdown sanitizer | Council | ✅ (34.4b) |

### Phase 33: Brain Surgery 2.5 (The "Pact" Polish)

**Goal:** Close the loop on social accountability and trust based on Google feedback.

**Status:** 🟢 COMPLETE

| ID | Recommendation | Advisor | Status |
|----|----------------|---------|--------|
| P1 | Add "Contract Card" before payment | Google | ✅ |
| P2 | Implement native Share Sheet for witness invite | Google | ✅ |
| P3 | Explicitly request Google Auth scopes | Google | ✅ |
| P4 | Polish Voice Coach placeholder | Google | ✅ |

---

## 📋 Backlog (Prioritised by "Council of Five")

### Phase 35: Provider Wiring (Post-NYE)

**Goal:** Wire new providers into main.dart using ProxyProvider.

**Priority:** HIGH (Enables testing, improves maintainability)

| ID | Task | Expert | Effort | Status |
|----|------|--------|--------|--------|
| W1 | Parallel repository initialisation in main.dart | Muratori | Low | [ ] |
| W2 | ProxyProvider for User → Habit dependency | Rousselet | Medium | [ ] |
| W3 | Integrate PsychometricProvider with AI services | Fowler | Medium | [ ] |
| W4 | Update GoRouter to use UserProvider | Rousselet | Low | [ ] |

### Phase 36: DTO Separation (Clean Architecture)

**Goal:** Separate domain entities from persistence concerns.

**Priority:** MEDIUM (Improves testability, enables DB swaps)

| ID | Task | Expert | Effort | Status |
|----|------|--------|--------|--------|
| D1 | Create HabitDTO for Hive persistence | Uncle Bob | Medium | [ ] |
| D2 | Create UserProfileDTO for Hive persistence | Uncle Bob | Medium | [ ] |
| D3 | Remove toJson/fromJson from domain entities | Uncle Bob | Low | [ ] |
| D4 | Create Mapper classes for DTO ↔ Domain | Evans | Medium | [ ] |

### Phase 37: HabitEngine Extraction

**Goal:** Extract business logic from AppState into pure domain service.

**Priority:** MEDIUM (Enables unit testing of core logic)

| ID | Task | Expert | Effort | Status |
|----|------|--------|--------|--------|
| H1 | Create HabitEngine domain service | Fowler | High | [ ] |
| H2 | Extract streak calculation logic | Fowler | Medium | [ ] |
| H3 | Extract recovery logic | Fowler | Medium | [ ] |
| H4 | Create HabitCompletionResult DTO | Evans | Low | [ ] |
| H5 | Create DomainEvent enum | Evans | Low | [ ] |

### Phase 38: IdentitySystem Aggregate

**Goal:** Unify user context into a single aggregate root.

**Priority:** LOW (Refinement, not critical)

| ID | Task | Expert | Effort | Status |
|----|------|--------|--------|--------|
| I1 | Create IdentitySystem aggregate root | Evans | High | [ ] |
| I2 | Merge UserProfile + PsychometricProfile | Evans | Medium | [ ] |
| I3 | Implement Ubiquitous Language | Evans | Low | [ ] |

### Post-Launch Features (Phase 39+)

**Goal:** Optimise retention and viral loops.

| ID | Feature | Priority | Status |
|----|---------|----------|--------|
| R1 | Push Notifications for Witness | High | [ ] |
| R2 | Deep Link handling for Invite Acceptance | High | [ ] |
| R3 | Voice Coach "Daily Standup" mode | Medium | [ ] |
| R4 | Apple Sign-In | Medium | [ ] |
| R5 | Offline-first sync with Supabase | Low | [ ] |

---

## ✅ Sprint History

### Completed (Phase 34.4) - Debug Diagnostics + Voice Coach UI
- [x] **Voice Coach Button:** Added "Voice Coach" option to Dashboard Add Habit bottom sheet.
- [x] **Oliver Backdoor Fix:** Moved backdoor from UserProvider to AppState.isPremium (which UI actually uses).
- [x] **In-App Debug Info:** Added `debugKeyStatus` to AIModelConfig showing key load status.
- [x] **Error Message Enhancement:** AI connection errors now show which keys are loaded/missing.
- [x] **Console Logging:** Added debug logging to AIServiceManager for logcat diagnosis.

### Completed (Phase 34.3) - Oliver Backdoor
- [x] **Oliver Backdoor:** Added temporary `isPremium` bypass for `oliver.longhurst@gmail.com`.
- [x] **Supabase Integration:** Backdoor uses `Supabase.instance.client.auth.currentUser?.email`.
- [x] **Documentation:** Updated all docs with Google Sign-In configuration details.
- [x] **Diagnostic Tool:** Created `lib/tool/diagnose_google_signin.dart` for SHA-1 verification.
- [x] **Validation Protocol:** Created `docs/VOICE_COACH_VALIDATION.md` for smoke test.

### Completed (Phase 34.2) - Shadow Wiring (Dark Launch)
- [x] **Repository Initialisation:** Added Hive repository instances to main.dart.
- [x] **Provider Injection:** Created providers with repository dependencies.
- [x] **MultiProvider Update:** Added new providers to app's provider tree.
- [x] **Debug Output:** Added console logging to confirm shadow wiring on startup.
- [x] **Strangler Pattern:** Legacy AppState coexists with new providers.

### Completed (Phase 34.1) - Council Approval + Muratori Fix
- [x] **Council Review:** Received GREEN LIGHT from all 5 experts.
- [x] **Muratori Caveat:** Implemented `recalibrateRisksAsync` with Isolate wrapper.
- [x] **Isolate Serialisation:** Added `toSerializableMap`/`fromSerializableMap` to Habit model.
- [x] **Documentation:** Updated AI_CONTEXT.md and ROADMAP.md with Council verdict.

### Completed (Phase 34) - Architecture Refactoring
- [x] **Repository Layer:** Created abstract interfaces and Hive implementations for Settings, User, Habit, Psychometric.
- [x] **Domain Providers:** Created SettingsProvider, UserProvider, HabitProvider, PsychometricProvider.
- [x] **PsychometricProfile:** Created rich domain entity with LLM system prompt generation.
- [x] **PsychometricEngine:** Created behavioural pattern analyser with incremental updates.
- [x] **Bitmask Risk Flags:** Implemented O(1) risk checks using bitmask pattern.
- [x] **Migration Guide:** Created comprehensive docs/ARCHITECTURE_MIGRATION.md.
- [x] **Voice Coach Rename:** Renamed voice_onboarding_screen.dart → voice_coach_screen.dart.
- [x] **Gradle Optimisation:** Updated gradle.properties for memory-constrained builds.

### Completed (Phase 33) - Brain Surgery 2.5
- [x] **The Pledge:** Added a "Contract Card" listing the specific habit, witness, and stakes before payment.
- [x] **Witness Invite:** Implemented native Share Sheet (`share_plus`) to send invite links via WhatsApp/SMS.
- [x] **Explicit Auth:** Verified Google Sign-In requests `email` and `profile` scopes explicitly.
- [x] **Voice Polish:** Added sound effects (`audioplayers`) to the AI Coach placeholder button.

### Completed (Phase 33) - The Investment
- [x] **TypeAhead Dependency:** Added `flutter_typeahead` to enable asynchronous contact searching.
- [x] **Permission Glass Pane:** Created a new reusable component to provide context before requesting OS permissions.
- [x] **Investment Screen:** Created a new screen that replaces the old `PactWitnessScreen`.
- [x] **Routing:** Updated the GoRouter configuration to replace the old witness screen with the new `WitnessInvestmentScreen`.

### Completed (Phase 32) - Audio Recording Integration
- [x] **Audio Dependencies:** Added `flutter_sound` and `permission_handler`.
- [x] **Audio Recording Service:** Created a new service to handle microphone initialisation and VAD.
- [x] **Voice Session Manager:** Created a new orchestration layer to manage the entire voice session.
- [x] **Voice Coach Screen:** Refactored the screen to use the new `VoiceSessionManager`.

### Completed (Phase 31) - "Final Polish" Sprint
- [x] **Default Identity:** Pre-selected the most popular identity chip.
- [x] **Reframe Witness:** Replaced "witness" with "supporter" (partially reverted in Phase 33).
- [x] **Haptic Feedback:** Added haptic feedback to chips.
- [x] **Pact Preview:** Added a "Pact Preview" card.
- [x] **Dashboard Personality:** Overhauled the empty state of the dashboard.
- [x] **Brand Tagline:** Added "THE PACT: Become who you said you'd be".

### Completed (Phase 30) - "Delight & Monetise" Sprint
- [x] **AI Coach Sample:** Added audio sample button.
- [x] **Privacy Controls:** Implemented "Privacy Controls".
- [x] **Confetti Celebration:** Added confetti explosion.
- [x] **Testimonials:** Added social proof testimonial widget.
- [x] **Binary Tier Choice:** Simplified to Free vs. Premium.

### Completed (Phase 29) - "Value & Safety" Sprint
- [x] **Hook Screen:** Created new initial screen with strong value prop.
- [x] **Graceful Consistency:** Added "No streaks. No shame." message.
- [x] **Progress Indicator:** Implemented visual step indicator.
- [x] **Benefit-Driven Headline:** Rewrote headline to "I want to become...".

---

## 🧠 Technical Debt Register

| ID | Description | Priority | Phase |
|----|-------------|----------|-------|
| **TD0** | **⚠️ Oliver Backdoor in AppState.isPremium** | **CRITICAL** | **Post-NYE** |
| **TD-1** | Debug diagnostics in production builds | Low | Post-NYE |
| TD1 | AppState is monolithic (1,642 lines) | Medium | 35-37 |
| TD2 | Habit.dart has toJson (violates Clean Architecture) | Low | 36 |
| TD3 | No DTO separation for persistence | Low | 36 |
| TD4 | HabitEngine logic embedded in AppState | Medium | 37 |
| TD5 | ConsistencyMetrics calculated on every access | Low | 37 |
| TD6 | landing_page/ React app in Flutter repo | Low | Future |

**TD0 Cleanup Command:**
```bash
grep -rn 'oliver.longhurst' lib/
# Remove the backdoor block from isPremium getter in user_provider.dart
```

---

## 📊 Architecture Evolution Timeline

```
Phase 33 (Dec 2025)     Phase 34 (Dec 2025)     Phase 35 (Jan 2026)     Phase 36-37 (Q1 2026)
       │                       │                       │                       │
       ▼                       ▼                       ▼                       ▼
┌─────────────┐         ┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│  Monolithic │         │  Repository │         │  Provider   │         │  Clean      │
│  AppState   │   →     │  Pattern    │   →     │  Wiring     │   →     │  Architecture│
│             │         │  + Domain   │         │  + Proxy    │         │  + DTOs     │
└─────────────┘         └─────────────┘         └─────────────┘         └─────────────┘
```

---

## 🎯 Success Metrics

### Launch (NYE 2025)
- [x] APK builds successfully (74s build time)
- [ ] Voice latency < 500ms
- [ ] No crashes on Xiaomi/MIUI
- [ ] Share Sheet works correctly
- [ ] Voice Coach accessible from Dashboard
- [ ] DeepSeek API connection working

### Post-Launch (Q1 2026)
- [ ] Unit test coverage > 60%
- [ ] AppState fully deprecated
- [ ] All domain entities are pure Dart
- [ ] Repository pattern enables mock testing
