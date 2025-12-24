# ROADMAP.md — The Pact

> **Last Updated:** 24 December 2025 (Commit: Phase 33 - Brain Surgery 2.5)  
> **Last Verified:** Phase 33 Complete (Contract Card + Share Sheet + Explicit Auth)  
> **Current Focus:** NYE 2025 LAUNCH  
> **Status:** 🟢 READY - Awaiting Final Smoke Test

---

## ⚠️ AI HANDOFF PROTOCOL

### Before Starting Work
1. Read `AI_CONTEXT.md` for current architecture state
2. Read `README.md` for project overview
3. Check `lib/config/deep_link_config.dart` (Domain: thepact.co)
4. Check `lib/data/services/gemini_live_service.dart` (Voice interface)
5. Check `lib/features/onboarding/voice_onboarding_screen.dart` (Voice UI)

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

## 📋 Backlog (Prioritised)

### Post-Launch (Phase 34)

**Goal:** Optimise retention and viral loops.

| ID | Feature | Priority | Status |
|----|---------|----------|--------|
| R1 | Push Notifications for Witness | High | [ ] |
| R2 | Deep Link handling for Invite Acceptance | High | [ ] |
| R3 | Voice Coach "Daily Standup" mode | Medium | [ ] |
| R4 | Apple Sign-In | Medium | [ ] |

---

## ✅ Sprint History

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
- [x] **Voice Onboarding Screen:** Refactored the screen to use the new `VoiceSessionManager`.

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
