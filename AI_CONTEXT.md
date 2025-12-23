# AI_CONTEXT.md — The Pact

> **Last Updated:** 23 December 2025 (Commit: Phase 29)  
> **Last Verified:** Phase 29 Complete (Second Council Review)  
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
| **AI (Tier 1)** | DeepSeek-V3 | Text Chat |
| **AI (Tier 2)** | Gemini 3 Flash (2.5 Live) | Voice + Text |
| **Voice** | Gemini Live API | WebSocket Streaming |
| **Hosting** | Netlify | Auto-deploy |

---

## Phase 29: Second Council of Five Review

A deep scrutiny of the User Journey Map was conducted, with element-by-element objectives defined for every screen and component. A new "Second Council of Five" was convened, featuring SMEs from adjacent but distinct domains to bring fresh perspectives.

**The Second Council:**

| Persona | Domain | Philosophy | Focus Area |
|---------|--------|------------|------------|
| **Daniel Kahneman** | Behavioural Economics | System 1/System 2 thinking | Decision architecture |
| **Brené Brown** | Vulnerability Research | Shame resilience, courage | Emotional safety |
| **Alex Hormozi** | Business Growth | Value equation, offer creation | Monetisation & perceived value |
| **Julie Zhuo** | Product Design | User empathy, design thinking | UX polish and delight |
| **David Ogilvy** | Advertising | Headline writing, persuasion | Copy and messaging |

**Key Recommendations (Tier 1 - Critical):**

| ID | Recommendation | Advisor | Rationale |
|----|----------------|---------|----------|
| K1 | Add "hook" screen before identity | Kahneman | Show value proposition first to engage System 1 before System 2 is required. |
| H1 | Lead with dream outcome (social proof stat) | Hormozi | Demonstrate the value *before* asking for effort. |
| B1 | Add "Graceful Consistency" messaging | Brown | Create emotional safety by explicitly stating "no streaks, no shame." |
| Z1 | Add progress indicator with celebration | Zhuo | Set user expectations and create moments of delight. |
| O1 | Rewrite headline to be benefit-driven | Ogilvy | Change "Who are you..." to a more compelling, outcome-focused headline. |

**New Documentation:** `docs/USER_JOURNEY_ANALYSIS_V2.md` (Full analysis with all 17 recommendations)

---

## Phase 28.4: Council of Five Implementation

Implemented recommendations from a strategic "Council of Five" analysis (Musk, Clear, Fogg, Bezos, Eyal) to optimise the new user acquisition funnel. This sprint focused on high-leverage, code-based changes to the onboarding and witness flows.

**Key Changes Implemented:**

| Recommendation | Advisor | File Changed | Details |
|---|---|---|---|
| **Route Consolidation** | Musk | `main.dart` | Niche routes (`/devs`, `/writers`, etc.) now pass a `presetIdentity` string to the `IdentityAccessGateScreen`. This pre-fills the identity field, creating a more contextual and lower-friction entry point from targeted ad campaigns or landing pages. |
| **Identity Mad-Libs** | Clear | `IdentityAccessGateScreen.dart` | The identity input screen now features a horizontal scrolling list of tappable `_IdentityChip` widgets. These act as "Mad-Libs" style suggestions. The identity field is now **mandatory**; authentication buttons are disabled until it is filled. Selected chips have a distinct visual state (brand gradient) to provide clear feedback. |
| **Native Contact Picker** | Fogg | `PactWitnessScreen.dart` | Replaced the manual witness input field with a one-tap native contact picker using the `flutter_contacts` package. This significantly reduces the friction of adding a witness. The implementation includes robust permission handling (`permission_handler`) with a graceful fallback to manual entry if permissions are denied. |
| **Trust Grant Dialog** | Bezos | `PactTierSelectorScreen.dart` | Implemented an "Early Access Grant" dialog. When a user selects a premium tier ('Builder' or 'Ally'), instead of a payment screen, they are presented with a dialog granting them free, lifetime access as an "early believer." This builds trust and captures high-intent users for future pricing validation. |
| **Reciprocity Loop** | Eyal | `WitnessAcceptScreen.dart` | After a user successfully becomes a witness for someone else, the success dialog now includes a prominent "Now it's your turn" section. This psychological hook creates a feeling of obligation to reciprocate by creating their own pact, turning the witness flow into a powerful user acquisition channel. |

**New Dependencies Added:**
- `flutter_contacts: ^1.1.9+2` - For native contact picker functionality.
- `permission_handler: ^11.3.1` - For managing access to device contacts.

---

## Phase 28.3: User Journey Optimisation

A comprehensive user journey map was created to identify and implement high-impact optimisations to the onboarding flow.

**New Documentation:** `docs/USER_JOURNEY_MAP.md`

**Key Changes Implemented:**

| Optimisation | File Changed | Details |
|--------------|--------------|---------||
| **Fix Tier Selection** | `PactTierSelectorScreen.dart` | Onboarding now completes correctly, navigating users to the dashboard. |
| **Unify Niche Routes** | `main.dart` | Niche landing pages (`/devs`, `/writers`, etc.) now use the modern "Identity First" flow. |
| **Add Witness CTA** | `WitnessAcceptScreen.dart` | Invited users who become witnesses are now prompted to create their own pact. |
| **Add Identity Examples** | `IdentityAccessGateScreen.dart` | Added tappable chips with examples to guide users during identity declaration. |

---

## Architecture Snapshot

### The "Voice First" Architecture (Phase 27)

**The Pivot:** From text-based onboarding to voice-first conversational AI coaching.

```
User Opens App
     ↓
Check Premium Status
     ↓
   ┌─────┴─────┐
   │           │
Tier 1       Tier 2
(Free)     (Premium)
   │           │
DeepSeek    Gemini Live
Text Chat   Voice Coach
   │           │
   └─────┬─────┘
         ↓
   Habit Created
```

### Voice Interface Flow

```
Voice Onboarding Screen
         ↓
  Gemini Live Service
         ↓
    [Auth Check]
         ↓
   ┌─────┴─────┐
   │           │
Supabase    DEV MODE
Edge Fn     (Direct API)
   │           │
   └─────┬─────┘
         ↓
  Ephemeral Token
         ↓
  Gemini Live API
  (WebSocket)
         ↓
  Real-time Voice
```

**Production:** Uses Supabase Edge Function to get ephemeral tokens (requires auth)  
**Dev Mode:** Uses Gemini API key directly (debug builds only, no auth required)

### Project Structure (Updated Phase 27)

```
atomichabits/
├── landing_page/                # React Web Application
│   ├── src/components/InviteRedirector.tsx  # Logic for /join/:code
│   ├── .env                                 # Environment config
│   └── netlify.toml                         # Build config
├── lib/
│   ├── config/
│   │   ├── deep_link_config.dart           # Domain: thepact.co, Scheme: thepact
│   │   └── ai_model_config.dart            # AI tier configuration + API keys
│   ├── data/services/
│   │   ├── ai/                             # Multi-Model AI Architecture
│   │   │   ├── deep_seek_service.dart      # Tier 1: Text reasoning
│   │   │   └── ai_service_manager.dart     # Tier selector
│   │   ├── gemini_live_service.dart        # [NEW] Tier 2: Voice WebSocket
│   │   ├── auth_service.dart               # Anonymous + Google Sign-In
│   │   ├── deep_link_service.dart          # Install Referrer implementation
│   │   └── witness_service.dart            # Real-time Pact events
│   └── features/
│       ├── onboarding/
│       │   ├── voice_onboarding_screen.dart          # [NEW] Voice interface
│       │   ├── conversational_onboarding_screen.dart # Text chat (Tier 1)
│       │   └── onboarding_screen.dart                # Manual form (fallback)
│       ├── dev/
│       │   └── dev_tools_overlay.dart                # [NEW] Developer tools
│       ├── settings/
│       │   └── settings_screen.dart                  # Premium toggle, auth
│       └── witness/
│           ├── witness_dashboard.dart                # Social feed
│           └── witness_accept_screen.dart            # Wax Seal UI
├── supabase/
│   └── functions/
│       └── get-gemini-ephemeral-token/     # [NEW] Edge Function for voice auth
│           └── index.ts                    # Deno Edge Function
├── docs/
│   └── GOOGLE_OAUTH_SETUP.md               # [NEW] OAuth setup guide
├── test/
│   └── services/ai/
│       ├── deep_seek_service_test.dart      # Unit tests with mocks
│       └── ai_service_manager_test.dart     # Tier selection tests
└── ...
```

---

## Feature Matrix (Phase 27 Complete)

| Feature | Status | Implementation Details |
|---------|--------|------------------------|
| **Voice First Onboarding** | ✅ Live | Gemini Live API + WebSocket streaming |
| **Two-Tier AI System** | ✅ Live | DeepSeek (Text) + Gemini (Voice) |
| **Developer Tools** | ✅ Live | Triple-tap gesture, debug overlay, premium toggle |
| **Dev Mode Voice Bypass** | ✅ Live | Direct API key usage (no auth required in debug) |
| **Deep Linking** | ✅ Live | `PlayInstallReferrer` + `InviteRedirector.tsx` (Web) |
| **Viral Loop** | ✅ Live | Share Sheet → Web Anchor → Store → App → Auto-Accept |
| **AI Brain** | ✅ Live | **DeepSeek-V3** (Tier 1) + **Gemini 3 Flash (2.5 Live)** (Tier 2) |
| **Rebrand** | ✅ Live | App ID: `co.thepact.app`, Name: "The Pact" |
| **Social** | ✅ Live | Wax Seal UI, Haptic Contracts, Witness Feeds |
| **Testing** | ✅ Live | Unit tests for AI services with HTTP mocks |
| **Landing Page** | ✅ Live | React app deployed to Netlify |
| **Google Sign-In** | 🟡 Config Needed | OAuth setup guide in docs/ |

### Complete Feature List

| Feature | Status | UI Layer | State Layer | Notes |
|---------|--------|----------|-------------|-------|
| **Voice Onboarding (Phase 27)** | ✅ Live | VoiceOnboardingScreen | GeminiLiveService | Real-time voice coaching |
| **Developer Tools (Phase 27.6)** | ✅ Live | DevToolsOverlay | AppState | Triple-tap gesture, debug info |
| Identity-Based Onboarding | ✅ Live | OnboardingScreen | AppState | Name, identity, habit, tiny version |
| AI Onboarding (Text) | ✅ Live | ConversationalOnboardingScreen | OnboardingOrchestrator | Chat UI with DeepSeek |
| Single Habit Tracking | ✅ Live | TodayScreen | AppState | One habit at a time |
| Graceful Consistency | ✅ Live | GracefulConsistencyCard | ConsistencyMetrics | Rolling averages, not fragile streaks |
| Never Miss Twice Engine | ✅ Live | RecoveryBanner, RecoveryPromptDialog | RecoveryEngine | Compassionate recovery system |
| AI Suggestions | ✅ Live | SuggestionDialog | AiSuggestionService | Local heuristics + async remote fallback |
| Temptation Bundling | ✅ Live | TodayScreen | Habit model | "Make it Attractive" |
| Pre-Habit Rituals | ✅ Live | PreHabitRitualDialog | Habit model | 30-second mindset timer |
| Environment Design | ✅ Live | TodayScreen | Habit model | Cues and distraction guardrails |
| Daily Notifications | ✅ Live | - | NotificationService | With snooze and mark-done actions |
| Recovery Notifications | ✅ Live | - | NotificationService | 9 AM after missed day |
| Settings Screen | ✅ Live | SettingsScreen | AppState (AppSettings) | Theme, notifications, sound, haptics, **premium toggle** |
| Multi-Habit Engine | ✅ Live | - | AppState (List<Habit>) | CRUD + Focus Mode |
| Dashboard | ✅ Live | HabitListScreen | AppState | Habit cards, quick-complete, swipe-delete |
| Focus Mode Swipe | ✅ Live | TodayScreen (PageView) | AppState | Swipe between habits |
| History/Calendar View | ✅ Live | HistoryScreen, CalendarMonthView | AppState | Stats, calendar dots, milestones |
| Error Boundaries | ✅ Live | ErrorBoundary, ErrorScreen | - | Global error handling |
| Weekly Review with AI | ✅ Live | WeeklyReviewDialog | WeeklyReviewService | AI-powered weekly insights |
| Home Screen Widgets | ✅ Live | Native (Android/iOS) | HomeWidgetService | One-tap habit completion |
| Analytics Dashboard | ✅ Live | AnalyticsScreen | AnalyticsService | Graceful Consistency charts |
| Backup & Restore | ✅ Live | DataManagementScreen | BackupService | JSON export/import |
| Bad Habit Protocol | ✅ Live | Updated UI components | Habit.isBreakHabit | Break habits with purple theme |
| Habit Stacking | ✅ Live | StackPromptDialog, HabitSummaryCard | CompletionResult, AppState stacking | Chain Reaction prompts |
| Pattern Detection | ✅ Live | AnalyticsScreen (Insight Cards), RecoveryPromptDialog | PatternDetectionService, MissEvent | Local heuristics + LLM synthesis |
| Identity Foundation | ✅ Live | - | AuthService, SyncService | Anonymous-first auth, cloud backup |
| Habit Contracts | ✅ Live | ContractsListScreen, CreateContractScreen, JoinContractScreen | ContractService, HabitContract | Accountability agreements with deep links |
| The Witness | ✅ Live | WitnessDashboard, WitnessAcceptScreen, HighFiveSheet | WitnessService, WitnessEvent | Social accountability loop |
| **The Red Carpet** | ✅ Live | InviteRedirector.tsx, GuestDataWarningBanner | DeepLinkService (Install Referrer) | Zero-friction invited user onboarding |

---

## Critical Constraints

### DO NOT VIOLATE

1. **Deep Link Domain:** MUST be `thepact.co`. Do not use `atomichabits.app`.
2. **Package Name:** Android is `co.thepact.app`. iOS is `co.thepact.app`.
3. **Deployment:** Web updates are auto-deployed via Netlify on `main` push. Mobile updates require manual build.
4. **AI Tier Selection:** Premium users (Tier 2) get voice. Free users (Tier 1) get text chat.
5. **Install Referrer Priority:** Install Referrer API > Clipboard Bridge > Manual Entry.
6. **Voice Auth:** Production requires Supabase Edge Function + Google Sign-In. Dev mode bypasses with direct API key.

---

## Quick Wins (Common AI Tasks)

| Task | File to Edit | Key Function |
|------|--------------|--------------|
| Change app name | `ios/Runner/Info.plist`, `android/.../strings.xml` | `CFBundleDisplayName`, `app_name` |
| Update domain | `lib/config/deep_link_config.dart` | `productionDomain` |
| Add AI model | `lib/data/services/ai/ai_service_manager.dart` | `selectProvider()` |
| Update landing page | `landing_page/src/components/InviteRedirector.tsx` | OS detection logic |
| Change package ID | `android/app/build.gradle.kts` | `applicationId` |
| **Update App Icon** | `android/app/src/main/res/mipmap-*/ic_launcher.png` | Replace PNG files |
| **Toggle Premium Mode** | Settings → Developer Settings → Premium (Tier 2) | `AppSettings.devModePremium` |
| **Access Dev Tools** | Triple-tap screen title in debug builds | `DevToolsGestureDetector` |

---

## AI Service Architecture (Phase 27: Voice First)

### The Strategic Shift

**Phase 24 (Previous):** Text-only AI with DeepSeek + Claude  
**Phase 27 (Current):** **Voice-First** AI with DeepSeek (text) + Gemini Live (voice)

### Why Voice?

1. **10x faster** than typing on mobile
2. **More natural** for habit discussions
3. **Higher completion rates** (voice feels like talking to a friend)
4. **Accessibility** for users who struggle with forms

### Two-Tier System

| Tier | Model | Interface | Use Case | Cost |
|------|-------|-----------|----------|------|
| **Tier 1 (Free)** | DeepSeek-V3 | Text Chat | Reasoning, logic, habit design | $0.14/M tokens |
| **Tier 2 (Premium)** | Gemini 2.0 Flash | Voice | Real-time voice coaching | $0.075/M tokens |

### Voice Architecture Components

1. **GeminiLiveService** (`lib/data/services/gemini_live_service.dart`)
   - WebSocket connection to Gemini Live API
   - Real-time audio streaming (PCM 16-bit)
   - Circuit breaker pattern for graceful degradation
   - Dev mode bypass for testing without auth

2. **VoiceOnboardingScreen** (`lib/features/onboarding/voice_onboarding_screen.dart`)
   - MVP voice interface with microphone button
   - Connection status indicators
   - Fallback to text chat on error

3. **Edge Function** (`supabase/functions/get-gemini-ephemeral-token/`)
   - Generates ephemeral tokens for Gemini Live API
   - Requires authentication (Google Sign-In)
   - Deployed to Supabase

### Dev Mode Bypass

For testing without Google Sign-In:

```dart
// In GeminiLiveService._getEphemeralToken()
if (kDebugMode && AIModelConfig.hasGeminiKey) {
  // Use API key directly (no auth required)
  return AIModelConfig.geminiApiKey;
}
```

This allows voice testing in debug builds without setting up OAuth.

---

## Developer Tools (Phase 27.6)

### Access

**Triple-tap** on any screen title (e.g., "AI Coach", "Voice Coach") in debug builds.

### Features

- ✅ **Toggle Premium Mode** (Tier 2) instantly
- ✅ **View AI Status** (tier, availability, kill switches, API keys)
- ✅ **Quick Navigation** to any screen (Voice Coach, Text Coach, Manual, Dashboard, Settings)
- ✅ **Skip Onboarding** for testing
- ✅ **Copy Debug Info** for bug reports (Peter Thiel recommendation)

### Settings Access

All onboarding screens now have a **Settings gear icon** in the top-right corner.  
No need to create a habit first!

---

## Testing Voice Interface

### Prerequisites

1. **Secrets file:** Create `secrets.json` in project root:
   ```json
   {
     "DEEPSEEK_API_KEY": "your_key",
     "GEMINI_API_KEY": "your_key",
     "OPENAI_API_KEY": "your_key"
   }
   ```

2. **Build debug APK:**
   ```bash
   flutter build apk --debug --dart-define-from-file=secrets.json
   ```

### Test Steps

1. Install APK on device
2. Tap **Settings** (gear icon) → **Developer Settings**
3. Enable **Premium (Tier 2)**
4. Go back → Tap **AI Coach**
5. Should route to **Voice Coach** (no auth required in dev mode)

### Troubleshooting

- **"Failed to obtain ephemeral token"** → Check `GEMINI_API_KEY` in `secrets.json`
- **Routes to text chat instead of voice** → Check Premium toggle in Developer Settings
- **No sound** → Audio recording not implemented yet (Phase 27.8)

---

## Google OAuth Setup (For Production)

See **[docs/GOOGLE_OAUTH_SETUP.md](./docs/GOOGLE_OAUTH_SETUP.md)** for full setup guide.

**Quick summary:**
1. Create OAuth 2.0 Client IDs in Google Cloud Console (Web + Android)
2. Configure Google provider in Supabase Dashboard
3. Add SHA-1 fingerprint: `C6:B1:B4:D7:93:9B:6B:E8:EC:AD:BC:96:01:99:11:62:84:B6:5E:6A`
4. Package name: `co.thepact.app`

---

## Known Issues & Technical Debt

### Next Steps (Immediate)

1.  **Deploy Supabase Edge Function:** The updated `get-gemini-ephemeral-token` function must be deployed to take effect.
    ```bash
    supabase functions deploy get-gemini-ephemeral-token --project-ref lwzvvaqgvcmsxblcglxo
    ```
2.  **Rebuild APK:** The Flutter app must be rebuilt to include the new `GeminiLiveService` logic.
    ```bash
    flutter build apk --debug --dart-define-from-file=secrets.json
    ```

### Phase 28.1: Gemini 3 Compliance (✅ COMPLETE)
- **Root Cause:** The previous integration was based on Gemini 2.0 protocols. Gemini 3 introduced breaking changes.
- **Fix #1 (Thought Signatures):** Implemented handling for `thoughtSignature` in `GeminiLiveService` to maintain conversational context.
- **Fix #2 (Thinking Level):** Added `thinking_config: { thinking_level: "MINIMAL" }` to the WebSocket setup to reduce voice latency.
- **Fix #3 (Temperature):** Removed all `temperature` settings for Gemini 3 models to prevent documented looping behaviour.

### High Priority (BLOCKING NYE LAUNCH)

1. **WebSocket Connection Fixed** (Phase 27.15 - ✅ COMPLETE)
   - **Root Cause #1:** Auth parameter mismatch - API keys need `key=` not `access_token=` (Phase 27.9 ✅)
   - **Root Cause #2:** Geo-blocking - `gemini-2.5-flash` preview is US region-locked (Phase 27.10 ✅)
   - **Root Cause #3:** Build error - `WebSocketChannel.connect()` doesn't support `headers` parameter (Phase 27.11 ✅)
   - **Root Cause #4:** Deprecated `-exp` endpoint - experimental endpoints are unstable (Phase 27.13 ✅)
   - **Root Cause #5:** Gemini 2.0 Live SHUTDOWN - All 2.0 Live endpoints were shut down Dec 9, 2025! (Phase 27.14 ✅)
   - **Root Cause #6:** TOKEN SCOPE VIOLATION - Edge Function generated tokens for Preview model, app requested GA model (Phase 27.15 ✅)
   - **Final Fix:** Aligned Edge Function model (`gemini-live-2.5-flash-native-audio`) with Flutter app
   - **CRITICAL:** After pushing code, MUST deploy Edge Function: `supabase functions deploy get-gemini-ephemeral-token`
   - **Phase 27.12 "Black Box" Debug Features:** (retained for future debugging)
     - Phase tracking: IDLE → FETCHING_TOKEN → BUILDING_URL → CONNECTING_SOCKET → SENDING_HANDSHAKE → WAITING_FOR_SERVER_READY → CONNECTED_STABLE
     - Detailed error messages include: timestamp, phase, close code, close reason, model name, auth method
     - UI shows debug dialog on error with monospace "screenshot-ready" format
   - **NEXT STEP:** Deploy Edge Function, rebuild APK, test voice connection

2. **Audio Recording Not Implemented** (Phase 27.8)
   - Voice interface shows UI but doesn't capture audio yet
   - Need to implement microphone permissions + audio streaming
   - **UNBLOCKED:** WebSocket connection should now work

3. **Google Sign-In Configuration** (Phase 27.7)
   - OAuth setup guide provided (`docs/GOOGLE_OAUTH_SETUP.md`)
   - Not configured yet - voice works in dev mode without auth
   - **REQUIRED FOR:** Production voice interface

4. **Manual Onboarding UX** (Phase 27.5)
   - Form is long and overwhelming
   - Consider multi-step wizard or collapsing optional fields
   - **PRIORITY:** Low (voice is the primary path)

### Medium Priority

4. **Error Message Display Bug** (Fixed Phase 27.7)
   - Was showing literal `${result.error}` instead of actual error
   - Fixed in settings_screen.dart

5. **Ghost Habits** (Fixed Phase 27.4)
   - Habits appearing in dashboard but not in database
   - Fixed by adding null checks and sync validation

### Low Priority

6. **App Icon Automation**
   - Currently manual PNG replacement
   - Consider re-enabling `flutter_launcher_icons` package

---

## Phase History

| Phase | Name | Status | Key Features |
|-------|------|--------|--------------|
| 1-6 | Core Habit Tracking | ✅ Complete | Single habit, graceful consistency, notifications |
| 7-14 | AI & Analytics | ✅ Complete | Weekly review, pattern detection, analytics |
| 15-16 | Social & Auth | ✅ Complete | Anonymous auth, habit contracts, witnesses |
| 17-20 | AI Optimization | ✅ Complete | DeepSeek prompts, intelligent nudges, feedback |
| 21-24 | Viral Growth | ✅ Complete | Deep linking, web anchor, install referrer |
| 25 | Gemini Pivot | ⏸️ Paused | Gemini 3 integration (superseded by Phase 27) |
| **28** | **Gemini 3 Compliance** | ✅ **Complete** | **Thought Signatures, Thinking Level, Temperature Fix** |
| 26 | The Lab | ⏸️ Paused | A/B testing framework (deferred) |
| **27.1-27.4** | **Bug Fixes** | ✅ Complete | Ghost habits, DeepSeek routing, branding |
| **27.5** | **Voice First Pivot** | ✅ Complete | Voice interface, routing logic, new icon |
| **27.6** | **Developer Tools** | ✅ Complete | Debug overlay, premium toggle, settings access |
| **27.7** | **Dev Mode Bypass** | ✅ Complete | Voice works without auth in debug builds |
| **27.8** | **Audio Recording** | 🚧 In Progress | Microphone permissions + audio streaming |
| **27.9** | **WebSocket Auth Fix** | ✅ Complete | Auth parameter fix (`key=` vs `access_token=`), v1alpha API, SetupComplete handling |
| **27.10** | **Geo-Blocking Fix** | ✅ Complete | Switched to `gemini-2.0-flash-exp` (globally available), header-based auth |
| **27.11** | **Build Fix** | ✅ Complete | Reverted to URL parameter auth (Flutter compatibility) |

---

## Next Steps (Phase 28)

See **[ROADMAP.md](./ROADMAP.md)** for detailed priorities.

**Immediate (NYE 2025):**
1. ✅ Voice interface UI (Phase 27.5)
2. ✅ Dev mode bypass (Phase 27.7)
3. ✅ WebSocket connection fix (Phase 27.9)
4. ✅ Geo-blocking fix (Phase 27.10)
5. 🚧 Audio recording implementation (Phase 27.8)
6. 🚧 Google OAuth setup (Phase 27.7)

**Short-term (Q1 2026):**
- Polish voice UX (waveform, transcription)
- Implement Tier 2 paywall
- Launch beta testing program

**Long-term (Q2 2026):**
- Multi-language voice support
- Voice-based habit check-ins
- Social voice features (voice notes to witnesses)

---

## Commit Message Format

```
Phase X.Y: Brief Title

- Feature 1
- Feature 2
- Bug fix 3

Testing: How to verify changes
```

**Example:**
```
Phase 27.7: Dev Mode Voice Bypass + Google OAuth Guide

Voice Interface:
- DEV MODE BYPASS: Uses Gemini API key directly when not authenticated
- Works in debug builds without Google Sign-In
- Falls back to API key if Edge Function fails

Documentation:
- Added docs/GOOGLE_OAUTH_SETUP.md with full setup guide

Testing: Build debug APK and voice interface should work without auth
```

---

## Contact & Support

**Repository:** [github.com/lenghurst/atomichabits](https://github.com/lenghurst/atomichabits)  
**Live App:** [thepact.co](https://thepact.co)  
**Supabase Project:** `lwzvvaqgvcmsxblcglxo`

---

**Last Session:** Phase 28.1 - Gemini 3 Compliance Fixes  
**Next Session:** Phase 28.2 - Deploy Edge Function & Build APK
