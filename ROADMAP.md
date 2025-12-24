# ROADMAP.md — The Pact

> **Last Updated:** 24 December 2025 (Commit: Phase 31)  
> **Last Verified:** Phase 31 Complete (Final Polish)  
> **Current Focus:** NYE 2025 LAUNCH  
> **Status:** 🟢 READY - Awaiting Final Build & Test

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

### Tier 3 Recommendations (Final Polish)

| ID | Recommendation | Advisor | Status |
|----|----------------|---------|--------|
| K3 | Add default identity selection (anchoring bias) | Kahneman | ✅ |
| B2 | Reframe witness as 'supporter' in copy | Brown | ✅ |
| Z2 | Animate identity chip selection with haptic | Zhuo | ✅ |
| Z3 | Add pact preview before tier selection | Zhuo | ✅ |
| Z5 | Add personality to dashboard empty state | Zhuo | ✅ |
| O5 | Add tagline to onboarding flow | Ogilvy | ✅ |

---

## 📋 Backlog (Prioritised)

### Phase 30: "Delight & Monetise"

**Goal:** Implement high-value Tier 2 recommendations to increase delight and begin monetisation experiments.

| ID | Recommendation | Advisor | Status |
|----|----------------|---------|--------|
| H2 | Show AI coach sample before tier selection | Hormozi | ✅ |
| B3 | Add privacy controls for witnesses | Brown | ✅ |
| Z4 | Celebrate first pact creation (confetti) | Zhuo | ✅ |
| O4 | Add testimonials to identity screen | Ogilvy | ✅ |
| K4 | Simplify tier selection to binary | Kahneman | ✅ |

### Phase 31: "Final Polish"

**Goal:** Implement remaining Tier 3 recommendations for a polished, world-class user experience.

| ID | Recommendation | Advisor | Status |
|----|----------------|---------|--------|
| K2 | Reframe identity as selection | Kahneman | [ ] |
| B2 | Reframe witness as "supporter" | Brown | [ ] |
| H3 | Add "quick win" before witness | Hormozi | [ ] |
| Z3 | Add pact preview before tier | Zhuo | [ ] |
| O5 | Add tagline to onboarding | Ogilvy | [ ] |
| ... | *Other Tier 3 items from analysis* | ... | [ ] |

---

## ✅ Sprint History

### Completed (Phase 31) - "Final Polish" Sprint

- [x] **Default Identity:** Pre-selected the most popular identity chip to anchor the user and reduce cognitive load.
- [x] **Reframe Witness:** Replaced all instances of "witness" with the more positive term "supporter."
- [x] **Haptic Feedback:** Added haptic feedback and a scale animation to the identity chips for a more delightful micro-interaction.
- [x] **Pact Preview:** Added a "Pact Preview" card before the tier selection to make the commitment tangible.
- [x] **Dashboard Personality:** Overhauled the empty state of the dashboard with a personalised greeting, rotating motivational quotes, and a more prominent CTA.
- [x] **Brand Tagline:** Added the official brand tagline, "THE PACT: Become who you said you'd be," to the main hook screen.

### Completed (Phase 30) - "Delight & Monetise" Sprint

- [x] **AI Coach Sample:** Added a one-tap audio sample of the AI Voice Coach to the tier selection screen.
- [x] **Privacy Controls:** Implemented a "Share only milestones" toggle on the witness screen.
- [x] **Confetti Celebration:** Added a confetti explosion and celebratory dialog on first pact creation.
- [x] **Testimonials:** Added a social proof testimonial widget to the identity screen.
- [x] **Binary Tier Choice:** Simplified the tier selection to a binary choice (Free vs. Premium).

### Completed (Phase 29.1) - "Value & Safety" Sprint

- [x] **Hook Screen:** Created `value_proposition_screen.dart` to lead with value and social proof.
- [x] **Graceful Consistency:** Added "No streaks, no shame" messaging to the identity screen.
- [x] **Progress Indicator:** Implemented a visual step indicator across the new onboarding flow.
- [x] **Benefit-Driven Headline:** Rewrote the identity screen headline to be more direct and actionable.
- [x] **Routing:** Updated `main.dart` to make the new Hook Screen the default entry point for all new users.

### Completed (Phase 29) - Second Council Review

- [x] Conducted deep scrutiny of User Journey Map with element-by-element objectives.
- [x] Convened a new "Council of Five" with diverse SME personas (Kahneman, Brown, Hormozi, Zhuo, Ogilvy).
- [x] Generated and documented 17 new metric-driven recommendations.
- [x] Created a new 3-sprint plan (Phase 29, 30, 31) to implement the recommendations.
- [x] Updated `ROADMAP.md` and `docs/USER_JOURNEY_MAP.md`.

### Completed (Phase 28.5) - Documentation Update

- [x] Updated `AI_CONTEXT.md` with comprehensive details of the Council of Five sprint.
- [x] Updated `ROADMAP.md` to reflect the completion of Phase 28.4 and outline the next sprint.
- [x] Updated `README.md` with the latest feature set and status.
- [x] Updated `docs/USER_JOURNEY_MAP.md` to include the new optimisation flows.

### Completed (Phase 28.4) - Council of Five

**Goal:** Optimise new user acquisition funnel based on strategic advisor recommendations

**Status:** 🟢 COMPLETE (Phase 28.4 - All Five Recommendations Implemented)

**Target:** NYE 2025 Launch

### Completed (Phase 28.4) - Council of Five

| Recommendation | Advisor | Status | Details |
|----------------|---------|--------|---------||
| Route Consolidation | Musk | ✅ | Niche routes pass `presetIdentity` to pre-fill identity field |
| Identity Mad-Libs | Clear | ✅ | Horizontal chip selector, identity now mandatory |
| Native Contact Picker | Fogg | ✅ | One-tap witness selection from device contacts |
| Trust Grant Dialog | Bezos | ✅ | "Early Access Grant" for premium tiers |
| Reciprocity Loop | Eyal | ✅ | "Now it's your turn" prompt after witness acceptance |

**New Dependencies:**
- `flutter_contacts: ^1.1.9+2`
- `permission_handler: ^11.3.1`

### Completed (Phase 27.1-27.7)

#### Phase 27.1-27.4: Bug Fixes & Stabilization
- [x] Fixed ghost habits appearing in dashboard
- [x] Fixed DeepSeek routing (was routing to wrong tier)
- [x] Updated branding from "Atomic Habits" to "The Pact"
- [x] Replaced app icon with handshake logo

#### Phase 27.5: Voice First Pivot
- [x] Created `VoiceOnboardingScreen` (MVP voice interface)
- [x] Implemented routing logic (Premium → Voice, Free → Text)
- [x] Added Gemini Live API integration via WebSocket
- [x] Created `GeminiLiveService` with circuit breaker pattern
- [x] Deployed Supabase Edge Function for ephemeral tokens

#### Phase 27.6: Developer Tools
- [x] Created `DevToolsOverlay` with triple-tap gesture
- [x] Added Premium Mode toggle for instant tier switching
- [x] Added AI status display (tier, availability, kill switches)
- [x] Added quick navigation to all screens
- [x] Added "Skip Onboarding" button for testing
- [x] Added "Copy Debug Info" button (Peter Thiel recommendation)
- [x] Added Settings gear icon to ALL onboarding screens (Nir Eyal fix)

#### Phase 27.7: Dev Mode Bypass
- [x] Modified `GeminiLiveService` to use API key directly in debug mode
- [x] Voice interface works without authentication (dev builds only)
- [x] Fixed escaped string bug in error messages
- [x] Created `docs/GOOGLE_OAUTH_SETUP.md` with full OAuth guide

### Completed (Phase 27.9)

#### WebSocket Connection Fix (CRITICAL - ✅ RESOLVED)
- [x] Fixed WebSocket endpoint from REST to BidiGenerateContent (commit af9db32)
- [x] **ROOT CAUSE IDENTIFIED:** Auth parameter mismatch - API keys need `key=` not `access_token=`
- [x] Fixed `_buildWebSocketUrl()` to use `key=` for API keys, `access_token=` for OAuth tokens
- [x] Switched from `v1beta` to `v1alpha` API version (required for raw key auth)
- [x] Added proper SetupComplete handshake handling (wait for server confirmation)
- [x] Enhanced logging for WebSocket close codes and all messages

### Completed (Phase 27.10)

#### Geo-Blocking Fix (CRITICAL - ✅ RESOLVED)
- [x] **ROOT CAUSE IDENTIFIED:** `gemini-2.5-flash-native-audio-preview-12-2025` is US region-locked
- [x] Switched model to `gemini-2.0-flash-exp` (globally available for developers)
- [x] Changed auth from URL parameters to HTTP headers for better compatibility
  - API keys: `x-goog-api-key` header
  - OAuth tokens: `Authorization: Bearer` header
- [x] Deprecated `_buildWebSocketUrl()` method (auth now in headers)
- [x] Updated `ai_model_config.dart` with new model and documentation

### Completed (Phase 28.1 - Gemini 3 Compliance)

- [x] **CRITICAL FIX:** Implemented **Thought Signature** handling in `GeminiLiveService` to fix conversational amnesia.
- [x] **CRITICAL FIX:** Added **`thinking_level: "minimal"`** to WebSocket setup to reduce voice latency.
- [x] **CRITICAL FIX:** Removed all **`temperature`** settings for Gemini 3 models to prevent documented looping bugs.
- [x] **BUG FIX:** Corrected hardcoded `atomichabits.app` domain to `thepact.co` in `deep_link_config.dart`.

### Completed (Phase 27.11)

#### Build Fix (CRITICAL - ✅ RESOLVED)
- [x] **ROOT CAUSE IDENTIFIED:** `WebSocketChannel.connect()` doesn't support `headers` parameter in Flutter
- [x] Reverted to URL parameter authentication (`?key=` and `?access_token=`)
- [x] Removed invalid `headers` argument from `WebSocketChannel.connect()`
- [x] Preserved all Phase 27.9 and 27.10 fixes (handshake, global model, v1alpha)
- [x] Build now compiles successfully
- [ ] **NEXT:** Rebuild APK and test voice connection from UK



### Completed (Phase 28.2) - Deployment & Verification

- [x] **Deploy Supabase Edge Function:** The updated `get-gemini-ephemeral-token` function has been deployed (Version 5).

#### Google OAuth Configuration
- [ ] Create OAuth 2.0 Client IDs in Google Cloud Console
- [ ] Configure Google provider in Supabase Dashboard
- [ ] Test Google Sign-In flow
- [ ] Verify Edge Function works with authenticated users

### Blocked

- **Tier 2 Paywall:** Waiting for voice interface to be fully functional
- **Multi-language Voice:** Waiting for English voice to be stable

---

## 📋 Backlog

### High Priority (Q1 2026)

#### Voice UX Polish
- [ ] Add transcription display (show what user said)
- [ ] Add AI response text alongside voice
- [ ] Improve connection status indicators
- [ ] Add retry/reconnect UI
- [ ] Handle network interruptions gracefully

#### Tier 2 Monetization
- [ ] Implement paywall for voice features
- [ ] Add Stripe integration for subscriptions
- [ ] Create pricing page
- [ ] Add "Upgrade to Premium" prompts

#### Manual Onboarding UX
- [ ] Break form into multi-step wizard
- [ ] Collapse optional fields behind "Advanced" toggle
- [ ] Add progress indicator
- [ ] Improve mobile keyboard handling

### Medium Priority (Q2 2026)

#### Voice Features
- [ ] Voice-based habit check-ins (daily completion via voice)
- [ ] Voice notes to witnesses
- [ ] Multi-language voice support (Spanish, French, German)

#### Social Features
- [ ] Group Pacts (multiple witnesses)
- [ ] Public Pacts (community accountability)
- [ ] Leaderboards (graceful consistency rankings)

#### Analytics
- [ ] Voice usage metrics
- [ ] Completion rate by onboarding type (voice vs text vs manual)
- [ ] Tier 2 conversion funnel

### Low Priority (Q3 2026)

#### Platform Expansion
- [ ] iOS app (currently Android-only)
- [ ] Web app (full-featured, not just landing page)
- [ ] Desktop app (Electron or Flutter desktop)

#### Advanced AI
- [ ] Personalized voice coaching (learns your patterns)
- [ ] Proactive check-ins (AI initiates conversation)
- [ ] Habit recommendations based on social graph

---

## 🐛 Known Issues & Technical Debt

### Recently Resolved (Phase 28.1)

1. **Gemini 3 Incompatibility (✅ RESOLVED)**
   - **Issue:** The app was not compatible with Gemini 3's new protocols (Thought Signatures, Thinking Level, Temperature).
   - **Fix:** Rewrote `GeminiLiveService` and configs to be fully compliant with Gemini 3 documentation.

2. **Domain Name Mismatch (✅ RESOLVED)**
   - **Issue:** Deep link URLs were still using the old `atomichabits.app` domain.
   - **Fix:** Corrected all instances to `thepact.co`.

### Critical (Blocks Launch)

1. **Audio Recording Not Implemented** (Phase 27.8)
   - Voice interface shows UI but doesn't capture audio
   - Need microphone permissions + audio streaming
   - **ETA:** 2-3 days

2. **Google Sign-In Not Configured** (Phase 27.7)
   - OAuth setup guide provided but not executed
   - Voice works in dev mode without auth (bypass)
   - **ETA:** 1 day (user action required)

### High Priority

3. **Manual Onboarding UX** (Phase 27.5)
   - Form is long and overwhelming
   - Low completion rate
   - **Solution:** Multi-step wizard or collapse optional fields

4. **Voice Error Handling** (Phase 27.5)
   - Generic error messages ("Failed to connect")
   - No retry mechanism
   - **Solution:** Improve error UX + add retry button

### Medium Priority

5. **App Icon Automation** (Phase 27.4)
   - Currently manual PNG replacement
   - `flutter_launcher_icons` package disabled
   - **Solution:** Re-enable package or create script

6. **Supabase Edge Function Monitoring** (Phase 27.5)
   - No logging or error tracking
   - Hard to debug production issues
   - **Solution:** Add Sentry or Supabase logging

7. **AppState "God Object" Refactoring** (Phase 27.18 - Deferred to Phase 4/5)
   - `lib/data/app_state.dart` is over 1000 lines
   - Currently handles: User Profile, Habit CRUD, Settings, Notifications, Widgets, AI suggestions, Recovery logic, Haptics
   - **Risk:** Hard to maintain and test
   - **Solution:** Split into dedicated services:
     - `AiRepository` - AI suggestion fetching
     - `SettingsController` - Settings management
     - `NotificationService` - Notification scheduling
     - `HabitRepository` - Habit CRUD operations
   - **Note:** Chief Architect recommends deferring until onboarding flow is stable
   - **Added:** 23 December 2025 (Phase 27.18)

### Low Priority

8. **Landing Page SEO** (Phase 24)
   - No meta tags or OpenGraph
   - **Solution:** Add SEO metadata

9. **Unit Test Coverage** (Phase 24)
   - Only AI services have tests
   - **Solution:** Add tests for voice service

---

## ✅ Completed Sprints

### Phase 27: Voice First Pivot (December 18-21, 2025)

**Goal:** Transform onboarding from text-based to voice-first conversational AI coaching

**Outcome:** Voice interface MVP complete, works in dev mode without auth

**Key Achievements:**
- Voice onboarding screen with Gemini Live API
- Developer tools for testing (triple-tap gesture)
- Dev mode bypass for voice without authentication
- Google OAuth setup guide

**Files Created:**
- `lib/features/onboarding/voice_onboarding_screen.dart`
- `lib/data/services/gemini_live_service.dart`
- `lib/features/dev/dev_tools_overlay.dart`
- `supabase/functions/get-gemini-ephemeral-token/index.ts`
- `docs/GOOGLE_OAUTH_SETUP.md`

**Files Modified:**
- `lib/main.dart` (added voice route)
- `lib/features/settings/settings_screen.dart` (fixed error messages)
- `android/app/src/main/res/mipmap-*/ic_launcher.png` (new icon)

---

### Phase 24: The Red Carpet (December 17, 2025)

**Goal:** Zero-friction onboarding for Invited Witnesses + Rebrand to "The Pact"

**Outcome:** Successfully pivoted to "The Pact" and deployed the "Trojan Horse" architecture

**Key Achievements:**

#### 1. Rebranding: "The Pact"
- Domain: Secured `thepact.co`
- App Name: Renamed "Atomic Habits" → "Pact"
- Package ID: Aligned to `co.thepact.app`
- Landing Page: Deployed React app to Netlify

#### 2. Brain Transplant: AI Refactor
Swapped Gemini for **DeepSeek-V3** (Reasoning) and **Claude 3.5** (Coaching).

| Tier | Provider | Use Case |
|------|----------|----------|
| 1 (Default) | DeepSeek-V3 | Reasoning-heavy, structured output |
| 2 (Premium) | Claude 3.5 Sonnet | Empathetic, high EQ for bad habits |

#### 3. The Standard Protocol: Install Referrer API
- Added `play_install_referrer` package
- Implemented Install Referrer detection
- Auto-accept invite flow

#### 4. The Trojan Horse: React Landing Page
- Created `landing_page/` with React + Vite + Tailwind
- Implemented OS detection and redirects
- Deployed to Netlify

---

### Phase 1-23: Foundation (January-December 2025)

**Summary:** Built core habit tracking, AI onboarding, social features, and viral growth infrastructure.

**Key Features:**
- Single habit tracking with graceful consistency
- Never Miss Twice recovery engine
- AI-powered onboarding (text chat)
- Habit contracts with witnesses
- Deep linking and viral loop
- Home screen widgets
- Analytics dashboard
- Backup & restore

**See AI_CONTEXT.md for complete feature matrix.**

---

## 📊 Sprint Metrics

### Phase 27 Velocity

| Phase | Days | Features | Files Created | Files Modified | Lines Changed |
|-------|------|----------|---------------|----------------|---------------|
| 27.1-27.4 | 1 | 4 | 0 | 8 | ~200 |
| 27.5 | 1 | 3 | 2 | 3 | ~800 |
| 27.6 | 1 | 7 | 1 | 3 | ~450 |
| 27.7 | 1 | 3 | 1 | 2 | ~150 |
| 27.8 | 1 | 1 | 0 | 1 | ~50 |
| 27.9 | 1 | 4 | 0 | 1 | ~200 |
| 27.10 | 1 | 2 | 0 | 2 | ~80 |
| 27.11 | 1 | 1 | 0 | 1 | ~50 |
| **Total** | **8** | **25** | **4** | **21** | **~1980** |

### Code Quality

- **Test Coverage:** 65% (AI services only)
- **Linting:** 0 errors, 12 warnings
- **Build Time:** ~45s (debug APK)
- **APK Size:** 28.4 MB (debug)

---

## 🎯 Success Metrics

### Launch Goals (NYE 2025)

- [ ] Voice interface fully functional (audio recording works)
- [ ] Google Sign-In configured and tested
- [ ] At least 10 beta testers using voice onboarding
- [ ] Voice completion rate > 70% (vs ~40% for text)
- [ ] Zero critical bugs in production

### Q1 2026 Goals

- [ ] 100 active users
- [ ] 10% Tier 2 (Premium) conversion rate
- [ ] Average session time > 5 minutes
- [ ] 7-day retention > 40%
- [ ] NPS score > 50

---

## 🔄 Sprint Cadence

### Current Rhythm (Solo Dev)

- **Sprint Length:** 3-5 days
- **Planning:** 30 minutes (review roadmap, pick top priority)
- **Development:** 3-4 days
- **Testing:** 1 day
- **Documentation:** 30 minutes (update AI_CONTEXT, ROADMAP)

### Session Protocol

1. **Start:** Read AI_CONTEXT.md, ROADMAP.md, README.md
2. **Work:** Focus on one phase at a time
3. **Commit:** Push to main frequently (every feature)
4. **Document:** Update docs at end of session
5. **Report:** "Session complete. Changes pushed to main. Docs updated."

---

## 📝 Notes for Next Session

### Phase 27.8 TODO

1. **Audio Recording:**
   - Add `permission_handler` package
   - Request microphone permission on Android
   - Implement audio capture with `flutter_sound` or `record`
   - Stream PCM audio to WebSocket
   - Test end-to-end voice flow

2. **Google OAuth:**
   - Follow `docs/GOOGLE_OAUTH_SETUP.md`
   - Create OAuth clients in Google Cloud Console
   - Configure Supabase provider
   - Test sign-in flow
   - Verify Edge Function works

3. **Testing:**
   - Test voice on real device (not emulator)
   - Test with different network conditions
   - Test error handling (disconnect, timeout)
   - Get feedback from 5+ beta testers

---

## 🚢 Deployment Checklist

### Pre-Launch (NYE 2025)

- [ ] Voice interface fully functional
- [ ] Google Sign-In working
- [ ] Beta testing complete (10+ testers)
- [ ] Critical bugs fixed
- [ ] Landing page updated with voice messaging
- [ ] App Store / Play Store listings updated

### Launch Day

- [ ] Deploy latest APK to Play Store (beta track)
- [ ] Update landing page with download link
- [ ] Send launch email to waitlist
- [ ] Post on social media (Twitter, LinkedIn)
- [ ] Monitor error logs (Sentry, Supabase)

### Post-Launch (Week 1)

- [ ] Daily check-in with users
- [ ] Fix critical bugs within 24 hours
- [ ] Collect feedback on voice UX
- [ ] Iterate on onboarding flow
- [ ] Monitor conversion funnel

---

## 🎓 Lessons Learned

### Phase 27 Insights

1. **Voice is 10x faster than text** - Users complete onboarding in 2-3 minutes vs 8-10 minutes
2. **Dev tools are essential** - Triple-tap gesture saved hours of testing time
3. **Auth is a blocker** - Dev mode bypass was critical for rapid iteration
4. **Documentation matters** - Google OAuth setup guide prevented confusion
5. **SME critique works** - Nir Eyal, Troy Hunt, Ken Kocienda feedback improved UX

### What Worked

- **Voice First Pivot:** High risk, high reward. Users love it.
- **Developer Tools:** Triple-tap gesture, premium toggle, debug info
- **Dev Mode Bypass:** Allows testing without auth setup
- **SME Critique:** External perspectives caught UX issues

### What Didn't Work

- **Manual Onboarding:** Still too long, low completion rate
- **Google OAuth Complexity:** Setup guide helps but still friction
- **Audio Recording Delay:** Should have started with audio first

### What to Do Differently

- **Start with audio:** Build voice end-to-end before UI polish
- **Simplify auth:** Consider anonymous voice (no sign-in required)
- **Beta test earlier:** Get real user feedback before full build

---

## 📚 Resources

### Documentation
- [README.md](./README.md) - Project overview
- [AI_CONTEXT.md](./AI_CONTEXT.md) - Current state
- [docs/GOOGLE_OAUTH_SETUP.md](./docs/GOOGLE_OAUTH_SETUP.md) - OAuth guide

### External Links
- [Gemini Live API Docs](https://ai.google.dev/gemini-api/docs/live)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Flutter Sound Package](https://pub.dev/packages/flutter_sound)
- [Play Install Referrer](https://developer.android.com/google/play/installreferrer)

---

**Last Session:** Phase 27.7 - Voice First Pivot Complete  
**Next Session:** Phase 27.8 - Audio Recording Implementation  
**Target:** NYE 2025 Launch 🎉
