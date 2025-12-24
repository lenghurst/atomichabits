# AI_CONTEXT.md — The Pact

> **Last Updated:** 24 December 2025 (Commit: Phase 33 - Brain Surgery 2.5)  
> **Last Verified:** Phase 33 Complete (Contract Card + Share Sheet + Explicit Auth)  
> **Identity:** The Pact  
> **Domain:** thepact.co

---

## ⚠️ AI HANDOFF PROTOCOL (READ FIRST!)

### The Problem This Solves
AI agents (Claude, Codex, etc.) working on this codebase have historically:
- Created documentation on feature branches that were never merged
- Left orphaned PRs with valuable work
- Recreated files that already existed on other branches
- Lost context between sessions
- **FAILED TO SYNC:** Applied patches locally but failed to push to remote, causing "It Works on My Machine" errors.

### Mandatory Session Start Checklist
```
□ 1. Read README.md (project overview, architecture)
□ 2. Read AI_CONTEXT.md (current state, what's implemented) ← YOU ARE HERE
□ 3. Read ROADMAP.md (what's next, priorities)
□ 4. Check for stale branches: git branch -r | wc -l
□ 5. If stale branches > 10, consider cleanup (see Branch Hygiene below)
```

### Mandatory Session End Checklist
```
□ 1. SAVE ALL FILES: Ensure no unsaved buffers exist.
□ 2. COMMIT ALL CHANGES: git commit -am "feat/fix: description"
□ 3. PUSH TO REMOTE: git push origin main
□ 4. Update AI_CONTEXT.md with any new features/changes
□ 5. Update ROADMAP.md if priorities changed
□ 6. Report to user: "Session complete. Changes pushed to main. Docs updated."
```

---

## Project Overview

**The Pact** — A social habit-tracking app that turns personal goals into socially binding contracts.

**Core Philosophy:** `Graceful Consistency > Fragile Streaks`

**Live URL:** [thepact.co](https://thepact.co)

**Tech Stack:**
| Component | Technology | Version |
|-----------|------------|---------|
| **Mobile** | Flutter | 3.35.4 |
| **Web** | React + Vite + Tailwind | Latest |
| **Backend** | Supabase | ^2.8.4 |
| **AI (Tier 1)** | DeepSeek-V3 | Text Chat |
| **AI (Tier 2)** | Gemini 3 Flash (2.5 Live) | Voice + Text |
| **Voice** | Gemini Live API | WebSocket Streaming |
| **Hosting** | Netlify | Auto-deploy |

---

## Phase 33: Brain Surgery 2.5 (The "Pact" Polish)

A critical architectural overhaul to close the loop on social accountability and trust.

**Key Changes Implemented:**

| Component | File(s) Changed | Details |
|---|---|---|
| **The Pledge** | `pact_tier_selector_screen.dart` | Added a "Contract Card" listing the specific habit, witness, and stakes before payment. Changed copy to "THE PLEDGE" and "I stake my reputation..." |
| **Witness Invite** | `witness_investment_screen.dart` | Implemented native Share Sheet (`share_plus`) to send invite links via WhatsApp/SMS. |
| **Explicit Auth** | `auth_service.dart` | Verified Google Sign-In requests `email` and `profile` scopes explicitly. |
| **Voice Polish** | `pact_tier_selector_screen.dart` | Added sound effects (`audioplayers`) to the AI Coach placeholder button. |

**New Dependencies:**
- `share_plus` (for native sharing)
- `audioplayers` (for sound effects)

---

## Phase 33: The Investment (Supporter Screen Redesign)

Redesigned the Supporter Screen as a high-stakes "Investment" phase, incorporating a modal bottom sheet, continuous voice integration, a TypeAhead contact search, and contextual permissions.

**Key Changes Implemented:**

| Component | File(s) Changed | Details |
|---|---|---|
| **TypeAhead Dependency** | `pubspec.yaml` | Added `flutter_typeahead` to enable asynchronous contact searching. |
| **Permission Glass Pane** | `permission_glass_pane.dart` | Created a new reusable component to provide context before requesting OS permissions. |
| **Investment Screen** | `witness_investment_screen.dart` | Created a new screen that replaces the old `PactWitnessScreen`. |
| **Routing** | `main.dart` | Updated the GoRouter configuration to replace the old witness screen with the new `WitnessInvestmentScreen`. |

**New Files Created:**
- `lib/features/onboarding/components/permission_glass_pane.dart`
- `lib/features/onboarding/identity_first/witness_investment_screen.dart`

---

## Phase 32: FEAT-01 - Audio Recording Integration

Implemented a robust audio recording and session management system to enable real-time voice conversations with the AI coach.

**Key Changes Implemented:**

| Component | File(s) Changed | Details |
|---|---|---|
| **Audio Dependencies** | `pubspec.yaml` | Added `flutter_sound` and `permission_handler`. |
| **Audio Recording Service** | `audio_recording_service.dart` | Created a new service to handle microphone initialisation and VAD. |
| **Voice Session Manager** | `voice_session_manager.dart` | Created a new orchestration layer to manage the entire voice session. |
| **Voice Onboarding Screen** | `voice_onboarding_screen.dart` | Refactored the screen to use the new `VoiceSessionManager`. |
| **Security Patch** | `voice_onboarding_screen.dart` | Added `WidgetsBindingObserver` to pause the voice session when backgrounded. |

**New Files Created:**
- `lib/data/services/audio_recording_service.dart`
- `lib/data/services/voice_session_manager.dart`

---

## Phase 31: "Final Polish" Sprint (Tier 3 Implementation)

Implemented the remaining Tier 3 recommendations from the Second Council of Five.

**Key Changes Implemented:**

| Recommendation | Advisor | File(s) Changed | Details |
|---|---|---|---|
| **Default Identity** | Kahneman | `identity_access_gate_screen.dart` | Pre-selected "A Morning Person". |
| **Reframe Witness** | Brown | `pact_witness_screen.dart` | Replaced "witness" with "supporter" (partially reverted in Phase 33 to "Witness" for higher stakes). |
| **Haptic Feedback** | Zhuo | `identity_access_gate_screen.dart` | Added haptic feedback to chips. |
| **Pact Preview** | Zhuo | `pact_tier_selector_screen.dart` | Added a "Pact Preview" card. |
| **Dashboard Personality** | Zhuo | `habit_list_screen.dart` | Overhauled the empty state of the dashboard. |
| **Brand Tagline** | Ogilvy | `value_proposition_screen.dart` | Added "THE PACT: Become who you said you'd be". |

---

## Phase 30: "Delight & Monetise" Sprint (Tier 2 Implementation)

Implemented the high-value Tier 2 recommendations.

**Key Changes Implemented:**

| Recommendation | Advisor | File(s) Changed | Details |
|---|---|---|---|
| **AI Coach Sample** | Hormozi | `pact_tier_selector_screen.dart` | Added audio sample button. |
| **Privacy Controls** | Brown | `pact_witness_screen.dart` | Implemented "Privacy Controls". |
| **Confetti Celebration** | Zhuo | `pact_tier_selector_screen.dart` | Added confetti explosion. |
| **Testimonials** | Ogilvy | `identity_access_gate_screen.dart` | Added social proof testimonial widget. |
| **Binary Tier Choice** | Kahneman | `pact_tier_selector_screen.dart` | Simplified to Free vs. Premium. |

---

## Phase 29: "Value & Safety" Sprint (Tier 1 Implementation)

Implemented the critical Tier 1 recommendations.

**Key Changes Implemented:**

| Recommendation | Advisor | File(s) Changed | Details |
|---|---|---|---|
| **Hook Screen** | Kahneman, Hormozi, Ogilvy | `value_proposition_screen.dart` | Created a new initial screen with strong value prop. |
| **Graceful Consistency** | Brown | `identity_access_gate_screen.dart` | Added "No streaks. No shame." message. |
| **Progress Indicator** | Zhuo | `value_proposition_screen.dart` | Implemented visual step indicator. |
| **Benefit-Driven Headline** | Ogilvy | `identity_access_gate_screen.dart` | Rewrote headline to "I want to become...". |
