# AI_CONTEXT.md — AI Agent Knowledge Checkpoint

> **Last Updated:** December 18, 2025 (Commit: TBD)  
> **Last Verified:** Phase 25 In Progress (Gemini 3 Pivot + The Lab + Wallet)  
> **Identity:** The Pact (formerly Atomic Habits Hook)  
> **Domain:** thepact.co

---

## ⚠️ AI HANDOFF PROTOCOL (READ FIRST!)

### The Problem This Solves
AI agents (Claude, Codex, etc.) working on this codebase have historically:
- Created documentation on feature branches that were never merged
- Left orphaned PRs with valuable work
- Recreated files that already existed on other branches
- Lost context between sessions

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
□ 1. Commit all changes to main branch
□ 2. Update AI_CONTEXT.md with any new features/changes
□ 3. Update ROADMAP.md if priorities changed
□ 4. Report to user: "Session complete. Changes pushed to main. Docs updated."
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
| **AI (Tier 1)** | DeepSeek-V3 | Latest |
| **AI (Tier 2)** | Gemini 3 Flash | Latest |
| **AI (Tier 3)** | Gemini 3 Pro | Latest |
| **Wallet** | Google Wallet API | GenericPass |
| **Hosting** | Netlify | Auto-deploy |

---

## Architecture Snapshot

### The "Trojan Horse" Configuration
We use a split architecture to handle viral growth:

1. **Mobile (`lib/`)**: Flutter app. Handles logic, state, and `thepact://` schemes.
2. **Web (`landing_page/`)**: React app. Handles `https://thepact.co` HTTP requests.
   - **Role:** Traffic Cop. Detects OS → Redirects to Store or displays marketing page.

### Project Structure (Updated)

```
atomichabits/
├── landing_page/                # [NEW] React Web Application
│   ├── src/components/InviteRedirector.tsx  # Logic for /join/:code
│   ├── .env                                 # Environment config
│   └── netlify.toml                         # Build config
├── lib/
│   ├── config/
│   │   ├── deep_link_config.dart           # Domain: thepact.co, Scheme: thepact
│   │   └── ai_model_config.dart            # DeepSeek & Claude Keys
│   ├── data/services/
│   │   ├── ai/                             # [NEW] Multi-Model AI Architecture
│   │   │   ├── deep_seek_service.dart      # Tier 1: Reasoning (The Architect)
│   │   │   ├── claude_service.dart         # Tier 2: Coaching (The Coach)
│   │   │   └── ai_service_manager.dart     # Tier Selector
│   │   ├── experimentation_service.dart    # [NEW] The Lab (A/B/X Testing)
│   │   ├── deep_link_service.dart          # Install Referrer implementation
│   │   └── witness_service.dart            # Real-time Pact events
│   └── features/
│       └── witness/
│           ├── witness_dashboard.dart       # Social feed
│           └── witness_accept_screen.dart   # Wax Seal UI
├── supabase/
│   └── functions/
│       └── create-wallet-pass/             # [NEW] Google Wallet JWT Signer
│           └── index.ts                    # Deno Edge Function
├── test/
│   └── services/ai/
│       ├── deep_seek_service_test.dart      # Unit tests with mocks
│       └── ai_service_manager_test.dart     # Tier selection tests
└── ...
```

---

## Feature Matrix (Phase 24 Complete)

| Feature | Status | Implementation Details |
|---------|--------|------------------------|
| **Deep Linking** | ✅ Live | `PlayInstallReferrer` + `InviteRedirector.tsx` (Web) |
| **Viral Loop** | ✅ Live | Share Sheet → Web Anchor → Store → App → Auto-Accept |
| **AI Brain** | ✅ Live | **DeepSeek-V3** (Default) + **Claude** (Premium) |
| **Rebrand** | ✅ Live | App ID: `co.thepact.app`, Name: "Pact" |
| **Social** | ✅ Live | Wax Seal UI, Haptic Contracts, Witness Feeds |
| **Testing** | ✅ Live | Unit tests for AI services with HTTP mocks |
| **Landing Page** | ✅ Live | React app deployed to Netlify |

### Complete Feature List

| Feature | Status | UI Layer | State Layer | Notes |
|---------|--------|----------|-------------|-------|
| Identity-Based Onboarding | ✅ Live | OnboardingScreen | AppState | Name, identity, habit, tiny version |
| Single Habit Tracking | ✅ Live | TodayScreen | AppState | One habit at a time |
| Graceful Consistency | ✅ Live | GracefulConsistencyCard | ConsistencyMetrics | Rolling averages, not fragile streaks |
| Never Miss Twice Engine | ✅ Live | RecoveryBanner, RecoveryPromptDialog | RecoveryEngine | Compassionate recovery system |
| AI Suggestions | ✅ Live | SuggestionDialog | AiSuggestionService | Local heuristics + async remote fallback |
| Temptation Bundling | ✅ Live | TodayScreen | Habit model | "Make it Attractive" |
| Pre-Habit Rituals | ✅ Live | PreHabitRitualDialog | Habit model | 30-second mindset timer |
| Environment Design | ✅ Live | TodayScreen | Habit model | Cues and distraction guardrails |
| Daily Notifications | ✅ Live | - | NotificationService | With snooze and mark-done actions |
| Recovery Notifications | ✅ Live | - | NotificationService | 9 AM after missed day |
| Vibecoding Architecture | ✅ Live | Controllers/Helpers/Widgets | - | Clean separation pattern |
| Settings Screen | ✅ Live | SettingsScreen | AppState (AppSettings) | Theme, notifications, sound, haptics |
| AI Onboarding (Phase 1) | ✅ Live | OnboardingScreen + MagicWandButton | OnboardingOrchestrator | Magic Wand auto-fill |
| AI Onboarding (Phase 2) | ✅ Live | ConversationalOnboardingScreen | OnboardingOrchestrator | Chat UI default route |
| Multi-Habit Engine (Phase 3) | ✅ Live | - | AppState (List<Habit>) | CRUD + Focus Mode |
| Dashboard (Phase 4) | ✅ Live | HabitListScreen | AppState | Habit cards, quick-complete, swipe-delete |
| Focus Mode Swipe (Phase 4) | ✅ Live | TodayScreen (PageView) | AppState | Swipe between habits |
| History/Calendar View (Phase 5) | ✅ Live | HistoryScreen, CalendarMonthView | AppState | Stats, calendar dots, milestones |
| Settings & Polish (Phase 6) | ✅ Live | SettingsScreen | AppState (AppSettings) | Theme, notifications, sound, haptics |
| Error Boundaries (Phase 6) | ✅ Live | ErrorBoundary, ErrorScreen | - | Global error handling |
| Weekly Review with AI (Phase 7) | ✅ Live | WeeklyReviewDialog | WeeklyReviewService | AI-powered weekly insights |
| Home Screen Widgets (Phase 9) | ✅ Live | Native (Android/iOS) | HomeWidgetService | One-tap habit completion |
| Analytics Dashboard (Phase 10) | ✅ Live | AnalyticsScreen | AnalyticsService | Graceful Consistency charts |
| Backup & Restore (Phase 11) | ✅ Live | DataManagementScreen | BackupService | JSON export/import |
| Bad Habit Protocol (Phase 12) | ✅ Live | Updated UI components | Habit.isBreakHabit | Break habits with purple theme |
| Habit Stacking (Phase 13) | ✅ Live | StackPromptDialog, HabitSummaryCard | CompletionResult, AppState stacking | Chain Reaction prompts |
| Pattern Detection (Phase 14) | ✅ Live | AnalyticsScreen (Insight Cards), RecoveryPromptDialog | PatternDetectionService, MissEvent | Local heuristics + LLM synthesis |
| Identity Foundation (Phase 15) | ✅ Live | - | AuthService, SyncService | Anonymous-first auth, cloud backup |
| Habit Contracts (Phase 16.2) | ✅ Live | ContractsListScreen, CreateContractScreen, JoinContractScreen | ContractService, HabitContract | Accountability agreements with deep links |
| Brain Surgery (Phase 17) | ✅ Live | AI Prompts | AtomicHabitsReasoningPrompts | DeepSeek-V3.2 optimized prompts |
| The Vibe Update (Phase 18) | ✅ Live | StackPromptDialog, AnimatedNudgeButton | SoundService, FeedbackPatterns | Sound + Haptics + Animations |
| The Intelligent Nudge (Phase 19) | ✅ Live | TimeDriftSuggestionDialog | OptimizedTimeFinder, NudgeCopywriter | Drift detection + Smart copy |
| Side Door Strategy (Phase 19) | ✅ Live | NicheLandingPages | NicheConfig, NichePromptAdapter | Persona-based marketing |
| Destroyer Defense (Phase 20) | ✅ Live | AlphaShieldBanner, FeedbackDialogs | FeedbackService | Bug bounty + Alpha shield |
| The Viral Engine (Phase 21) | ✅ Live | ShareContractSheet, DeepLinkService | DeepLinkConfig | Deep links infrastructure |
| The Witness (Phase 22) | ✅ Live | WitnessDashboard, WitnessAcceptScreen, HighFiveSheet | WitnessService, WitnessEvent | Social accountability loop |
| **The Red Carpet (Phase 24)** | ✅ Live | InviteRedirector.tsx, GuestDataWarningBanner | DeepLinkService (Install Referrer) | Zero-friction invited user onboarding |

---

## Critical Constraints

### DO NOT VIOLATE

1. **Deep Link Domain:** MUST be `thepact.co`. Do not use `atomichabits.app`.
2. **Package Name:** Android is `co.thepact.app`. iOS is `co.thepact.app`.
3. **Deployment:** Web updates are auto-deployed via Netlify on `main` push. Mobile updates require manual build.
4. **AI Tier Selection:** Bad habits MUST use Claude (Tier 2). Standard habits use DeepSeek (Tier 1).
5. **Install Referrer Priority:** Install Referrer API > Clipboard Bridge > Manual Entry.

---

## Quick Wins (Common AI Tasks)

| Task | File to Edit | Key Function |
|------|--------------|--------------|
| Change app name | `ios/Runner/Info.plist`, `android/.../strings.xml` | `CFBundleDisplayName`, `app_name` |
| Update domain | `lib/config/deep_link_config.dart` | `productionDomain` |
| Add AI model | `lib/data/services/ai/ai_service_manager.dart` | `selectProvider()` |
| Update landing page | `landing_page/src/components/InviteRedirector.tsx` | OS detection logic |
| Change package ID | `android/app/build.gradle.kts` | `applicationId` |

---

## AI Service Architecture (Phase 25: Gemini Pivot)

### The Strategic Shift

**Phase 24 (Previous):** Text-only AI with DeepSeek + Claude  
**Phase 25 (Current):** Multimodal AI with Gemini 3 native voice/vision

### Tier System

| Tier | Provider | Persona | Capabilities | Use Case |
|------|----------|---------|--------------|----------|
| 1 (Free) | **DeepSeek-V3** | The Mirror | Text only | Basic logging, cost-effective reasoning |
| 2 (Paid) | **Gemini 3 Flash** | The Agent | Native Audio/Vision | Real-time voice coach, visual accountability |
| 3 (Pro) | **Gemini 3 Pro** | The Architect | Deep Reasoning | Complex habit systems, long-term planning |
| 4 (Manual) | None | Manual Entry | None | No AI available |

### Selection Logic

```dart
// lib/config/ai_model_config.dart
static AiTier selectTier({
  required bool isPremiumUser,
  required bool isProUser,
}) {
  if (isProUser && hasGeminiKey) return AiTier.tier3;      // Pro → Gemini 3 Pro
  if (isPremiumUser && hasGeminiKey) return AiTier.tier2;  // Paid → Gemini 3 Flash
  if (hasDeepSeekKey) return AiTier.tier1;                 // Free → DeepSeek
  return AiTier.tier4;                                     // Fallback → Manual
}
```

### Why Gemini 3?

1. **Native Multimodal:** No separate STT/TTS needed (ElevenLabs eliminated)
2. **Real-time Latency:** <500ms via WebSocket streaming
3. **Cost-Effective:** ~$0.50/1M tokens (cheaper than Claude + voice synthesis)
4. **Future-Proof:** Google's flagship model with long-term support

### Files

**Phase 24 (Existing):**
- `lib/data/services/ai/deep_seek_service.dart` - Tier 1 (Text only)
- `lib/data/services/ai/claude_service.dart` - Tier 2 (Deprecated in Phase 25)
- `lib/data/services/ai/ai_service_manager.dart` - Unified tier management
- `test/services/ai/deep_seek_service_test.dart` - Unit tests with HTTP mocks
- `test/services/ai/ai_service_manager_test.dart` - Tier selection tests

**Phase 25 (New):**
- `lib/data/services/ai/gemini_live_service.dart` - WebSocket voice bridge
- `lib/data/services/experimentation_service.dart` - A/B/X testing framework
- `lib/data/services/manifesto_generator.dart` - Identity Manifesto image generation

---

## The Lab (Phase 25.6)

We are running A/B/X tests on critical conversion points.

### Experiment 1: The Hook (Onboarding Opener)
- **Variant A (Control):** "The Friend" (Compassionate)
- **Variant B:** "The Sergeant" (Tough Love)
- **Variant C:** "The Visionary" (Future Self)

### Experiment 2: The Whisper (Notification Timing)
- **Variant A (Control):** 15 min before
- **Variant B:** 4 hours before (Anticipation)
- **Variant C:** Random interval (Nudge)

### Experiment 3: The Manifesto (Reward Format)
- **Variant A:** Visual (Image)
- **Variant B:** Audio (Voice Note)
- **Variant C:** Haptic (Vibration Pattern)

---

## Hook & Hold Strategy (Phase 25.7)

**Day 0 (First 24h):**
- **Minute 0-10:** "Manifesto Generation" (Identity Anchor)
- **Hour 4:** "The Whisper" (Anticipation Nudge)
- **Hour Due:** "The Golden Minute" (Wax Seal Ceremony)
- **Hour 24:** "Day 1 Debrief" (Identity Evidence)

**Day 1-7 (Retention):**
- **Day 2:** "Ghost Protocol" (Concerned Friend Nudge)
- **Day 3:** "Micro-Step Fallback" (Negotiation)
- **Day 5:** "Pattern Recognition" (Insight Unlock)
- **Day 7:** "Weekly Review" (The Seed Box)

---

## Google Wallet Integration (Phase 25.8)

**Concept:** "The Pocket Totem" - A dynamic Identity Card in Google Wallet.

### Architecture
1. **Flutter:** User taps "Add to Wallet".
2. **Supabase Edge Function:** `create-wallet-pass`
   - Receives user ID + Habit Data.
   - Generates `GenericPass` JSON object.
   - Signs JWT using Google Service Account (RSA-SHA256).
   - Returns signed JWT string.
3. **Flutter:** Consumes JWT via `add_to_google_wallet` package.
4. **Google Wallet:** Displays pass and handles updates.

### Key Files
- `supabase/functions/create-wallet-pass/index.ts` - JWT Signer
- `lib/data/services/wallet_service.dart` - Frontend integration
