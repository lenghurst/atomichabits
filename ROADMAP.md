# ROADMAP.md — The Pact

> **Last Updated:** December 18, 2025 (Commit: TBD)  
> **Last Verified:** Phase 25 In Progress (Gemini 3 Pivot + The Lab + Wallet)  
> **Current Focus:** LAUNCH (New Year's Eve)  
> **Status:** 🟢 RELEASE CANDIDATE READY

---

## ⚠️ AI HANDOFF PROTOCOL

### Before Starting Work
1. Read `AI_CONTEXT.md` for current architecture state
2. Read `README.md` for project overview
3. Check `lib/config/deep_link_config.dart` (Domain: thepact.co)
4. Check `lib/data/services/ai/` (AI tier system)
5. Check `landing_page/` (React web anchor)

### After Completing Work
1. Update the relevant section below (move items, add details)
2. Add to Sprint History with date and changes
3. Update `AI_CONTEXT.md` with changes made
4. Commit all changes to `main` branch
5. Create/update PR with roadmap changes noted

---

## ✅ Completed Sprint: Phase 24 "The Red Carpet"

**Goal:** Zero-friction onboarding for Invited Witnesses + Rebrand to "The Pact"

**Outcome:** Successfully pivoted to "The Pact" and deployed the "Trojan Horse" architecture.

**Status:** ✅ Complete (December 17, 2025)

### Key Achievements

#### 1. Rebranding: "The Pact"
- [x] **Domain:** Secured `thepact.co`
- [x] **App Name:** Renamed "Atomic Habits" → "Pact"
  - iOS: `CFBundleDisplayName = "Pact"`
  - Android: `app_name = "Pact"`
- [x] **Package ID:** Aligned to `co.thepact.app`
  - `android/app/build.gradle.kts`: `applicationId = "co.thepact.app"`
  - `lib/config/deep_link_config.dart`: `androidPackage = "co.thepact.app"`
- [x] **Copywriting:** Updated share sheet to "I need a witness. Sign The Pact with me:"
- [x] **Landing Page:** Deployed React app with "The Pact" branding to Netlify

#### 2. Brain Transplant: AI Refactor
Swapped Gemini for **DeepSeek-V3** (Reasoning) and **Claude 3.5** (Coaching).

| Tier | Provider | Persona | Use Case |
|------|----------|---------|----------|
| 1 (Default) | **DeepSeek-V3** | The Architect | Reasoning-heavy, structured output |
| 2 (Premium) | **Claude 3.5 Sonnet** | The Coach | Empathetic, high EQ for bad habits |
| 3 (Fallback) | Gemini 2.5 Flash | AI Assistant | Fast, reliable backup |
| 4 (Manual) | None | Manual Entry | No AI available |

**Files Created:**
- `lib/data/services/ai/deep_seek_service.dart` - Tier 1 implementation
- `lib/data/services/ai/claude_service.dart` - Tier 2 implementation
- `lib/data/services/ai/ai_service_manager.dart` - Unified tier management
- `test/services/ai/deep_seek_service_test.dart` - Unit tests with mocks
- `test/services/ai/ai_service_manager_test.dart` - Tier selection tests

#### 3. The Standard Protocol: Install Referrer API
- [x] Added `play_install_referrer` package (v0.5.0)
- [x] Implemented Install Referrer detection in `DeepLinkService`
- [x] Added `checkForDeferredDeepLink()` with loading state handling
- [x] Updated `OnboardingOrchestrator` for Hard Bypass routing
- [x] Updated `ShareContractSheet` with Smart Link generation

**Flow:**
```
User A shares → https://thepact.co/join/XYZ
                        ↓
User B clicks → Play Store with referrer=invite_code%3DXYZ
                        ↓
User B installs → App reads PlayInstallReferrer
                        ↓
Auto-accept invite → Hard Bypass to WitnessAcceptScreen
```

#### 4. The Trojan Horse: React Landing Page
- [x] Created `landing_page/` directory with React + Vite + Tailwind
- [x] Implemented `InviteRedirector.tsx` for OS detection and redirects
- [x] Deployed to Netlify with auto-deploy on `main` push
- [x] Configured environment variables (`VITE_APP_NAME="The Pact"`)

**Architecture:**
- **Mobile (Android/iOS):** Redirects to app store with referrer params
- **Desktop:** Shows landing page with invite banner + email capture

#### 5. UI/UX Enhancements
- [x] "Wax Seal" animation (press-and-hold to sign)
- [x] Haptic feedback at 33%, 66%, 100% progress
- [x] Guest Data Warning banner (`GuestDataWarningBanner` widget)
- [x] Witness Accept Screen polish

#### 6. Testing Infrastructure
- [x] DeepSeekService unit tests with HTTP mocks
- [x] AIServiceManager tier selection tests
- [x] Dependency Injection refactor for testability

### Technical Debt Paid
- Refactored `AIModelConfig` to support multi-provider injection
- Aligned Android `applicationId` (`co.thepact.app`) with web redirects
- Cleaned up orphaned AI code from previous Gemini-only implementation

---

## 🚀 Current Sprint: Phase 25 "The Gemini Pivot"

**Goal:** Transform onboarding from text-based to voice-first with Gemini 3 multimodal capabilities.

**Status:** 🟡 In Progress (December 18-31, 2025)

**Target:** New Year's Eve (December 31, 2025)

### The Strategic Pivot

**Previous Architecture (Phase 24):**
- Tier 1: DeepSeek-V3 (Text only)
- Tier 2: Claude 3.5 Sonnet (Text only)
- Tier 3: Gemini 2.5 Flash (Fallback)

**New Architecture (Phase 25):**
- Tier 1: DeepSeek-V3 "The Mirror" (Text only - Free)
- Tier 2: Gemini 3 Flash "The Agent" (Native Voice/Vision - Paid)
- Tier 3: Gemini 3 Pro "The Architect" (Deep Reasoning - Pro)

**Why Gemini 3?**
- **Native Multimodal:** Audio/Video input & output without separate STT/TTS
- **Real-time Latency:** <500ms response time (WebSocket streaming)
- **Cost-Effective:** ~$0.50/1M tokens (cheaper than Claude + ElevenLabs)
- **Future-Proof:** Google's flagship model with long-term support

### Phase 25.1: The Context-Aware Storyteller

**Concept:** Pre-flight MCQ screening → Personalized voice conversation

- [ ] **Screening UI:** 3-question MCQ (Mission, Enemy, Vibe)
  - Q1: "What brings you to The Pact?" (Builder/Breaker/Restorer)
  - Q2: "What usually stops you?" (Forget/Lazy/Busy/Perfectionist)
  - Q3: "How should I hold you accountable?" (Friend/Sage/Sergeant)
- [ ] **Context Injection:** Pass MCQ answers to AI system prompt
- [ ] **Dynamic Opener:** AI references user's specific "Enemy" in first message

**Files Created:**
- `GEMINI_3_ONBOARDING_SPEC.md` - Full specification
- `lib/config/ai_model_config.dart` - Updated with Gemini 3 tiers

### Phase 25.2: Native Voice Bridge (Tier 2+)

- [ ] **GeminiLiveService:** WebSocket connection to Gemini 3 Multimodal Live API
- [ ] **Audio Pipeline:** Mic → Gemini → Speaker (native streaming)
- [ ] **Voice Activity Detection:** Silence detection for turn-taking
- [ ] **Persona Mapping:** Map "Drill Sergeant" → short sentences, "Friend" → empathetic tone

### Phase 25.3: Visual Accountability (Vision)

- [ ] **Camera Integration:** "Show me your habit" prompt
- [ ] **Gemini Vision:** Send image bytes to verify habit completion
- [ ] **Example:** User claims "I went to the gym" → AI: "Show me your gym shoes"

### Phase 25.4: Store Submission (Parallel Track)

### Priority 1: Store Submission

- [ ] **Screenshots:** Generate 6.5" and 5.5" screenshots using "The Pact" branding
- [ ] **Privacy Policy:** Host `privacy.md` on `thepact.co/privacy`
- [ ] **TestFlight/Internal Track:** Upload `v1.0.0` AAB/IPA
- [ ] **App Store Listing:** Update name, description, keywords
- [ ] **Play Store Listing:** Update name, description, screenshots

### Priority 2: The "Day 2" Problem

- [ ] **Recovery Logic Check:** Ensure `RecoveryEngine` triggers correctly on Jan 2nd if user misses Jan 1st
- [ ] **Notification Permission:** Rigorous testing of permission dialog timing
- [ ] **Witness Notifications:** Verify real-time notifications work on both platforms

### Priority 3: Marketing Assets

- [ ] **Social Preview:** Update `og:image` tags on the landing page
- [ ] **Short Links:** Verify `thepact.co` links render correctly in iMessage/WhatsApp
- [ ] **DNS Configuration:** Point `thepact.co` to Netlify (A record + CNAME)

### Known Risks

- [ ] **App Store Review:** Rejection risk if "social contract" is misinterpreted as gambling
  - **Mitigation:** Emphasize "accountability" and "social support" in description
- [ ] **DNS Propagation:** `thepact.co` may take 24-48h to fully propagate
  - **Mitigation:** Configure DNS 48h before launch
- [ ] **Install Referrer Reliability:** Some Android OEMs strip referrer params
  - **Mitigation:** Clipboard Bridge fallback already implemented

---

## 🧪 Phase 25.6: The Lab (Experimentation)

**Goal:** A/B/X Testing Framework for "Storyteller" optimization.

- [ ] **ExperimentationService:** Deterministic user bucketing (`lib/data/services/experimentation_service.dart`)
- [ ] **Experiment 1: The Hook:** Test "Friend" vs "Sergeant" vs "Visionary" openers
- [ ] **Experiment 2: The Whisper:** Test notification timing (15min vs 4hr vs Random)
- [ ] **Experiment 3: The Manifesto:** Test reward format (Visual vs Audio vs Haptic)
- [ ] **Analytics:** Log `experiment_exposure` events to Supabase/PostHog

---

## 🕰️ Phase 25.7: Hook & Hold (Day 0-7 Strategy)

**Goal:** The "First Week" Retention Loop.

### Day 0: The First 24 Hours
- [ ] **Manifesto Generation:** AI generates shareable "Identity Manifesto" image after onboarding
- [ ] **The Whisper:** Notification 4 hours before habit due time ("I haven't forgotten.")
- [ ] **The Golden Minute:** Haptic "Wax Seal" ceremony on completion
- [ ] **Day 1 Debrief:** Morning report focusing on "Identity Evidence" not just streaks

### Day 1-7: The Retention Loop
- [ ] **Day 2 (Ghost Protocol):** "Concerned Friend" nudge if no open by noon
- [ ] **Day 3 (Compassion Trap):** "Micro-Step Fallback" negotiation if struggling
- [ ] **Day 5 (Pattern Recognition):** AI points out user behavior patterns ("You respond well to...")
- [ ] **Day 7 (Weekly Review):** Unlock "The Seed Box" (Feature voting/Planting new habits)

---

## 💳 Phase 25.8: The Pact Identity Card (Google Wallet)

**Goal:** Create a tangible digital artifact that lives in the user's Google Wallet.

**Concept:** "The Pocket Totem" - A dynamic pass that updates with streaks.

- [ ] **Google Console:** Register as Wallet Issuer, create Generic Class template.
- [ ] **Supabase Edge Function:** `create-wallet-pass` (Signs JWT with Service Account).
- [ ] **Flutter Integration:** `add_to_google_wallet` package implementation.
- [ ] **Dynamic Updates:** Logic to update pass style (Gold for 7-day streak, Cracked for missed).
- [ ] **Geofencing:** Embed location data for lock screen notifications at the gym.

---

## Future Roadmap (Q1 2026)

### Phase 26: The Monetization Engine
- **"Skin in the Game":** Users stake money on their pacts
- **Pro Tier:** Unlimited active pacts, Gemini 3 Pro access, Priority support
- **Freemium Model:** 1 free pact (DeepSeek), $4.99/month for unlimited (Gemini 3 Flash)

### Phase 27: The Growth Loop
- **Public Pacts:** Share your journey publicly for extra accountability
- **Leaderboards:** Compete with friends on consistency scores
- **Pact Templates:** Pre-built pacts for common goals (fitness, reading, meditation)

### Phase 28: The AI Coach Evolution
- **Context Awareness:** AI analyzes "Time Drift" (Phase 19) to suggest schedule changes
- **Agentic Planning:** AI restructures complex habit systems
- **Personalized Nudges:** AI generates custom recovery messages based on user history

---

## Sprint History

### Phase 24: "The Red Carpet" (Dec 1-17, 2025)
**Commits:** `00ff445` (AI Refactor), `eaa48e5` (Install Referrer), `2f4da74` (Rebrand), `93d419b` (App ID Fix), `c4b0a34` (Landing Page)

**Key Achievements:**
- Rebranded to "The Pact"
- Deployed React landing page to Netlify
- Implemented Install Referrer API for Android
- Refactored AI system (DeepSeek + Claude)
- Created unit test suite for AI services

**Technical Debt:**
- Fixed App ID mismatch (com.example.* → co.thepact.app)
- Aligned all package identifiers across platforms

### Phase 23: "The Witness" (Nov 2025)
**Commits:** `125f45c`, `a29468b`, `23296e2`

**Key Achievements:**
- Implemented social accountability loop
- Real-time witness notifications
- High-five emoji reactions
- Pre-failure "shame nudge" system

### Phase 22: "The Social Graph" (Oct 2025)
**Key Achievements:**
- Supabase Realtime integration
- Witness dashboard
- Contract sharing UI

---

## Technical Debt Tracker

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

## Architecture Constraints

### Critical Rules (DO NOT VIOLATE)

1. **Deep Link Domain:** MUST be `thepact.co`. Do not use `atomichabits.app`.
2. **Package Name:** Android is `co.thepact.app`. iOS is `co.thepact.app`.
3. **Deployment:** Web updates are auto-deployed via Netlify on `main` push. Mobile updates require manual build.
4. **AI Tier Selection:** Bad habits MUST use Claude (Tier 2). Standard habits use DeepSeek (Tier 1).
5. **Install Referrer Priority:** Install Referrer API > Clipboard Bridge > Manual Entry.

### Performance Targets

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
