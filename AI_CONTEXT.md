# AI_CONTEXT.md — AI Agent Knowledge Checkpoint

> **Last Updated:** December 17, 2025 (Commit: c4b0a34)  
> **Last Verified:** Phase 24 Complete, Phase 25 Active  
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
| **AI (Tier 2)** | Claude 3.5 Sonnet | Latest |
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
│   │   ├── deep_link_service.dart          # Install Referrer implementation
│   │   └── witness_service.dart            # Real-time Pact events
│   └── features/
│       └── witness/
│           ├── witness_dashboard.dart       # Social feed
│           └── witness_accept_screen.dart   # Wax Seal UI
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

## AI Service Architecture (Phase 24)

### Tier System

| Tier | Provider | Persona | Use Case | Cost |
|------|----------|---------|----------|------|
| 1 (Default) | **DeepSeek-V3** | The Architect | Reasoning-heavy, structured output | 10-100x cheaper |
| 2 (Premium) | **Claude 3.5 Sonnet** | The Coach | Empathetic, high EQ for bad habits | Premium |
| 3 (Fallback) | Gemini 2.5 Flash | AI Assistant | Fast, reliable backup | Standard |
| 4 (Manual) | None | Manual Entry | No AI available | Free |

### Selection Logic

```dart
// lib/data/services/ai/ai_service_manager.dart
AiProvider selectProvider({required Habit habit, required UserProfile profile}) {
  if (habit.isBreakHabit) return AiProvider.claude;  // Bad habits need empathy
  if (profile.isPremium) return AiProvider.claude;   // Premium users get best
  return AiProvider.deepSeek;                        // Default: cost-effective reasoning
}
```

### Files

- `lib/data/services/ai/deep_seek_service.dart` - Tier 1 implementation
- `lib/data/services/ai/claude_service.dart` - Tier 2 implementation
- `lib/data/services/ai/ai_service_manager.dart` - Unified tier management
- `test/services/ai/deep_seek_service_test.dart` - Unit tests with HTTP mocks
- `test/services/ai/ai_service_manager_test.dart` - Tier selection tests

---

## Deep Link Architecture (Phase 24)

### Flow

```
User A shares → https://thepact.co/join/XYZ
                        ↓
User B clicks → InviteRedirector.tsx detects OS
                        ↓
Android → market://details?id=co.thepact.app&referrer=invite_code%3DXYZ
iOS → https://apps.apple.com/app/id...
Desktop → Landing page with invite banner
                        ↓
User B installs → App reads PlayInstallReferrer
                        ↓
Auto-accept invite → Hard Bypass to WitnessAcceptScreen
```

### Files

- `landing_page/src/components/InviteRedirector.tsx` - Web redirector
- `lib/data/services/deep_link_service.dart` - Install Referrer API
- `lib/config/deep_link_config.dart` - Domain and scheme configuration
- `lib/widgets/share_contract_sheet.dart` - Smart link generation

---

## Testing Infrastructure (Phase 24)

### Unit Tests

```bash
flutter test
```

### Key Test Files

- `test/services/ai/deep_seek_service_test.dart` - API parsing, errors, edge cases
- `test/services/ai/ai_service_manager_test.dart` - Tier selection, fallback, metadata

### Test Coverage

- ✅ DeepSeek API parsing (JSON, UTF-8, errors)
- ✅ Claude service dependency injection
- ✅ Tier selection logic (bad habits, premium users, fallback)
- ✅ HTTP mocking for offline testing

---

## Known Issues & Technical Debt

### High Priority

- [ ] **iOS Bundle ID:** Update to `co.thepact.app` (currently `com.atomichabits.hook`)
- [ ] **Apple App ID:** Update `appleAppId` in `deep_link_config.dart` with real Team ID
- [ ] **SHA256 Fingerprint:** Generate and update `androidSha256` for App Links

### Medium Priority

- [ ] **Widget Package Name:** Update `qualifiedAndroidName` in `home_widget_service.dart`
- [ ] **App Group ID:** Update iOS widget app group to `group.co.thepact.app.widget`

### Low Priority

- [ ] **Landing Page Analytics:** Add Supabase analytics to track invite clicks
- [ ] **Error Tracking:** Integrate Sentry or similar for crash reporting

---

## Performance Targets

- **App Launch:** < 2 seconds on mid-range Android
- **Habit Completion:** < 500ms from tap to confirmation
- **Witness Notification:** < 5 seconds from completion to notification
- **Landing Page Load:** < 1 second on 3G connection

---

## Contact & Support

- **GitHub:** [lenghurst/atomichabits](https://github.com/lenghurst/atomichabits)
- **Domain:** [thepact.co](https://thepact.co)
- **Backend:** Supabase (hosted)
- **Web Hosting:** Netlify (auto-deploy)
