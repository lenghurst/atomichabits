# AI_CONTEXT.md — The Pact

> **Last Updated:** 24 December 2025 (Commit: Phase 33 + Hot Mic Patch)  
> **Last Verified:** Phase 33 Complete (Investment Screen + Voice Safety)  
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

### Branch Hygiene Protocol
When stale branches accumulate (> 10 unmerged):
1. List branches: `git branch -r --no-merged main`
2. For each branch, check last commit: `git log -1 <branch>`
3. If > 30 days old with no activity: recommend deletion
4. If contains unmerged valuable code: recommend cherry-pick or rebase

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

## Phase 33: The Investment (Supporter Screen Redesign)

Redesigned the Supporter Screen as a high-stakes "Investment" phase, incorporating a modal bottom sheet, continuous voice integration, a TypeAhead contact search, and contextual permissions. This aligns with the specified goal of creating a more emotionally resonant and effective social contract.

**Key Changes Implemented:**

| Component | File(s) Changed | Details |
|---|---|---|
| **TypeAhead Dependency** | `pubspec.yaml` | Added `flutter_typeahead` to enable asynchronous contact searching. |
| **Permission Glass Pane** | `permission_glass_pane.dart` | Created a new reusable component to provide context before requesting OS permissions, significantly increasing grant rates. |
| **Investment Screen** | `witness_investment_screen.dart` | Created a new screen that replaces the old `PactWitnessScreen`. It features a modal UI, a visceral headline ("Who will witness your failure?"), and integrates the TypeAhead search and permission handling. |
| **Routing** | `main.dart` | Updated the GoRouter configuration to replace the old witness screen with the new `WitnessInvestmentScreen`. |

**New Files Created:**
- `lib/features/onboarding/components/permission_glass_pane.dart`
- `lib/features/onboarding/identity_first/witness_investment_screen.dart`

---

## Phase 32: FEAT-01 - Audio Recording Integration

Implemented a robust audio recording and session management system to enable real-time voice conversations with the AI coach. This is a critical step towards a fully voice-first user experience.

**Key Changes Implemented:**

| Component | File(s) Changed | Details |
|---|---|---|
| **Audio Dependencies** | `pubspec.yaml` | Added `flutter_sound` and `permission_handler` to manage microphone access and audio streaming. |
| **Audio Recording Service** | `audio_recording_service.dart` | Created a new service to handle microphone initialisation, recording lifecycle (start, stop, pause, resume), and audio data streaming. Includes voice activity detection (VAD) to minimise data transmission. |
| **Voice Session Manager** | `voice_session_manager.dart` | Created a new orchestration layer to manage the entire voice session. It integrates the `AudioRecordingService` and `GeminiLiveService`, handling state synchronisation, error recovery, and audio routing between the microphone, the AI, and the user's speaker. |
| **Voice Onboarding Screen** | `voice_onboarding_screen.dart` | Refactored the screen to use the new `VoiceSessionManager`. This simplifies the UI logic and provides a more robust and responsive user experience with real-time audio level visualisation. |
| **Security Patch** | `voice_onboarding_screen.dart` | Added `WidgetsBindingObserver` to pause the voice session when the app is backgrounded, preventing "Hot Mic" vulnerabilities. |

**New Files Created:**
- `lib/data/services/audio_recording_service.dart`
- `lib/data/services/voice_session_manager.dart`

---

## Phase 31: "Final Polish" Sprint (Tier 3 Implementation)

Implemented the remaining Tier 3 recommendations from the Second Council of Five to add a final layer of polish and delight to the user experience before launch.

**Key Changes Implemented:**

| Recommendation | Advisor | File(s) Changed | Details |
|---|---|---|---|
| **Default Identity** | Kahneman | `identity_access_gate_screen.dart` | Pre-selected the most popular identity chip ("A Morning Person") to anchor the user and reduce cognitive load. This simple change is proven to increase conversion by providing a clear starting point. |
| **Reframe Witness** | Brown | `pact_witness_screen.dart` | Replaced all instances of "witness" and "accountability partner" with the more positive and encouraging term "supporter." This reframing reduces the user's fear of being judged and increases their willingness to invite someone. |
| **Haptic Feedback** | Zhuo | `identity_access_gate_screen.dart` | Added haptic feedback and a subtle scale animation to the identity chips. This creates a more tactile and satisfying micro-interaction, making the selection process more delightful. |
| **Pact Preview** | Zhuo | `pact_tier_selector_screen.dart` | Added a "Pact Preview" card before the tier selection. This shows the user exactly what they are creating (their identity, their supporter, and the start date), making the abstract concept of a "pact" tangible and increasing their commitment. |
| **Dashboard Personality** | Zhuo | `habit_list_screen.dart` | Overhauled the empty state of the dashboard. It now includes a personalised greeting, a rotating motivational quote from James Clear, and a more prominent, encouraging call-to-action. This transforms a functional empty state into an inspiring and motivating experience. |
| **Brand Tagline** | Ogilvy | `value_proposition_screen.dart` | Added the official brand tagline, "THE PACT: Become who you said you'd be," to the main hook screen. This reinforces the brand's core promise and creates a more memorable and professional first impression. |

---

## Phase 30: "Delight & Monetise" Sprint (Tier 2 Implementation)

Implemented the high-value Tier 2 recommendations from the Second Council of Five to increase user delight and improve monetisation potential before launch.

**Key Changes Implemented:**

| Recommendation | Advisor | File(s) Changed | Details |
|---|---|---|---|
| **AI Coach Sample** | Hormozi | `pact_tier_selector_screen.dart` | Added a one-tap audio sample of the AI Voice Coach directly on the tier selection screen. This demonstrates the premium value *before* asking for payment, significantly increasing the perceived value of the premium tier. |
| **Privacy Controls** | Brown | `pact_witness_screen.dart` | Implemented a "Privacy Controls" section on the witness screen. Users can now choose to share only weekly milestones with their witness, not daily check-ins. This gives users a greater sense of control and emotional safety. |
| **Confetti Celebration** | Zhuo | `pact_tier_selector_screen.dart` | Added a confetti explosion and a celebratory dialog upon the user's first pact creation. This creates a moment of delight and positive reinforcement at a key moment in the user journey. |
| **Testimonials** | Ogilvy | `identity_access_gate_screen.dart` | Added a social proof testimonial widget to the identity screen. This provides a relatable success story to increase user motivation and conversion. |
| **Binary Tier Choice** | Kahneman | `pact_tier_selector_screen.dart` | Simplified the tier selection from three options (Free, Builder, Ally) to a binary choice (Free vs. Premium). This reduces cognitive load and makes the decision to upgrade much simpler. |

**New Dependencies Added:**
- `confetti: ^0.7.0` - For the celebration animation.

---

## Phase 29: "Value & Safety" Sprint (Tier 1 Implementation)

Implemented the critical Tier 1 recommendations from the Second Council of Five to maximise user value and emotional safety before launch. This sprint focused on creating a "Value First, Identity Second" onboarding flow.

**Key Changes Implemented:**

| Recommendation | Advisor | File(s) Changed | Details |
|---|---|---|---|
| **Hook Screen** | Kahneman, Hormozi, Ogilvy | `value_proposition_screen.dart`, `main.dart` | Created a new initial screen that leads with a strong value proposition (3x more likely to succeed) and social proof (testimonial carousel). This engages the user's System 1 thinking before asking for commitment. The default route `/` now points to this screen. |
| **Graceful Consistency** | Brown | `identity_access_gate_screen.dart` | Added a prominent message ("We measure progress, not perfection. No streaks. No shame.") to the identity screen. This creates emotional safety and reduces the fear of failure, a key drop-off point. |
| **Progress Indicator** | Zhuo | `value_proposition_screen.dart`, `identity_access_gate_screen.dart` | Implemented a visual step indicator across the onboarding flow. This sets clear expectations for the user, reducing cognitive load and increasing completion rates. |
| **Benefit-Driven Headline** | Ogilvy | `identity_access_gate_screen.dart` | Rewrote the main headline from the ambiguous "Who are you committed to becoming?" to the more direct and actionable "I want to become...". This clarifies the user's task and reduces friction. |

**New Files Created:**
- `lib/features/onboarding/identity_first/value_proposition_screen.dart`

---

## Phase 29: Second Council of Five Review

A deep scrutiny of the User Journey Map was conducted, with element-by-element objectives defined for every screen and component. A new "Second Council of Five" was convened, featuring SMEs from adjacent but distinct domains to bring fresh perspectives.

**The Second Council:**

| Persona | Domain | Philosophy | Focus Area |
|---------|--------|------------|------------|
| **Daniel Kahneman** | Behavioural Economics | System 1/System 2 thinking | Decision architecture |
| **Brené Brown** | Vulnerability Research | Shame resilience, courage | Emotional safety |
