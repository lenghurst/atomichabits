# The Pact

> **"Don't rely on willpower. Rely on your friends."**

A social habit-tracking app that turns personal goals into socially binding contracts.  
Built on **Flutter** (Mobile) with **Voice-First AI Coaching**.

**Live URL:** [thepact.co](https://thepact.co)

---

## 📊 Status

| Component | Status | URL |
|-----------|--------|-----|
| **Mobile App** | 🟢 Phase 31 - LAUNCH READY | _NYE 2025 Target_ |
| **Landing Page** | 🟢 Live | [thepact.co](https://thepact.co) |
| **Backend** | 🟢 Live | Supabase + Edge Functions |
| **Voice AI** | 🟡 Pending Test | Gemini 3 Live API (Awaiting Final Smoke Test) |

> **Last Updated:** December 24, 2025 (Commit: Phase 31)  
> **Current Phase:** Phase 31 - Final Polish Complete

---

## 🎙️ Voice First Pivot (Phase 27)

**The Pact** is pivoting from text-based onboarding to **voice-first conversational AI coaching**.

### Why Voice?

- **10x faster** than typing on mobile
- **More natural** for habit discussions
- **Higher completion rates** (voice feels like talking to a friend)
- **Accessibility** for users who struggle with forms

### Two-Tier AI System

| Tier | Model | Interface | Use Case |
|------|-------|-----------|----------|
| **Tier 1 (Free)** | DeepSeek-V3 | Text Chat | Reasoning, logic, habit design |
| **Tier 2 (Premium)** | Gemini Live | Voice | Real-time voice coaching |

**Dev Mode:** Enable "Premium (Tier 2)" in Settings → Developer Settings to test voice interface.

---

## 🤖 AI Agent Quick Start

### The "Big Three" Documentation Files

| File | Purpose | When to Update |
|------|---------|----------------|
| **README.md** | Project overview, architecture, user-facing docs | On major features |
| **AI_CONTEXT.md** | Current state checkpoint for AI agents | Every session end |
| **ROADMAP.md** | Priorities, sprint tracking, technical debt | Every session end |

### Project Structure

```
atomichabits/
├── android/              # Native Android (Package: co.thepact.app)
├── ios/                  # Native iOS (Bundle: co.thepact.app)
├── lib/                  # === FLUTTER MOBILE APP ===
│   ├── features/
│   │   ├── onboarding/
│   │   │   ├── voice_onboarding_screen.dart      # NEW: Voice interface
│   │   │   ├── conversational_onboarding_screen.dart  # Text chat
│   │   │   └── onboarding_screen.dart            # Manual form (fallback)
│   │   ├── dev/
│   │   │   └── dev_tools_overlay.dart            # NEW: Developer tools
│   │   └── ...
│   ├── data/
│   │   └── services/
│   │       ├── gemini_live_service.dart          # NEW: Voice WebSocket
│   │       └── ...
│   └── config/
│       └── ai_model_config.dart                  # AI tier configuration
├── supabase/
│   └── functions/
│       └── get-gemini-ephemeral-token/           # Edge Function for voice auth
├── docs/                 # === DOCUMENTATION ===
│   ├── GOOGLE_OAUTH_SETUP.md                     # NEW: OAuth setup guide
│   └── ...
└── landing_page/         # === REACT WEB ANCHOR (The Trojan Horse) ===
```

---

## 🎯 The Core Philosophy

Traditional habit apps fail because they rely on **you**.  
**The Pact** relies on **us**.

1. **The Contract:** You don't just "set a goal." You sign a **Pact** with a friend (Witness).
2. **The Wax Seal:** A haptic-heavy, ceremonial UI that makes commitment feel weighty.
3. **The Witness:** Your friend gets notified when you succeed (or fail).
4. **Graceful Consistency:** We measure rolling consistency, not fragile streaks.
5. **Voice First:** Talk to your AI coach like a friend, not a form.

---

## 🏗️ Architecture: "The Unified Front"

We use a **Hybrid Viral Architecture** to ensure invite links work everywhere.

1. **The Signal (Mobile App):**
   - Generates a link: `https://thepact.co/join/XYZ`

2. **The Anchor (React Web):**
   - Hosted on Netlify.
   - Detects OS (Android/iOS/Desktop).
   - **Mobile:** Redirects to App Store / Play Store with `referrer` params.
   - **Desktop:** Shows a high-fidelity landing page to capture emails.

3. **The Receiver (Mobile App):**
   - Uses `PlayInstallReferrer` API on Android to auto-accept invites after install.
   - Bypasses onboarding for invited users ("The Red Carpet").

### Voice Architecture (NEW)

```
User → Voice Onboarding Screen
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

---

## 🛠️ Tech Stack

| Component | Technology | Role |
|-----------|------------|------|
| **Mobile** | Flutter 3.35.4 | The Core Experience |
| **Web** | React + Vite + Tailwind | The Landing Page / Redirector |
| **Backend** | Supabase | Auth, Database, Realtime, Edge Functions |
| **AI (Tier 1)** | DeepSeek-V3 | Text reasoning & logic |
| **AI (Tier 2)** | Gemini 3 Flash (2.5 Live) | Real-time voice coaching |
| **Voice** | Gemini Live API | WebSocket audio streaming |
| **Hosting** | Netlify | Web Deployment |

---

## 🚀 Next Steps: Final Build & Smoke Test

**Phases 29 & 30 have implemented the Second Council of Five recommendations. The final step before launch is a full smoke test.**

### 1. Get New Dependencies

Run `flutter pub get` to install the new contact picker dependencies:

```bash
flutter pub get
```

### 2. Rebuild the Mobile App (APK)

The Flutter app must be rebuilt to include all the new onboarding flows.

```bash
flutter build apk --debug --dart-define-from-file=secrets.json
```

### 3. Perform the Final Smoke Test

1. Install the newly built APK on a physical Android device.
2. **Test Hook Screen & Tagline:** On first open, verify the new "Value Proposition" screen appears with the "Become who you said you'd be" tagline.
3. **Test Default Identity & Haptics:** Proceed to the identity screen. Verify "A Morning Person" is pre-selected and that tapping other chips gives haptic feedback.
4. **Test Supporter Reframing:** Proceed to the witness screen. Verify all copy refers to "Supporter," not "Witness."
5. **Test Pact Preview:** Proceed to the tier screen. Verify the "Your Pact Preview" card appears before the tier options.
6. **Test AI Coach Sample:** Tap the "Play Sample" button on the tier screen and verify the audio plays.
7. **Test Confetti:** Complete the onboarding flow and verify the confetti celebration appears.
8. **Test Dashboard Empty State:** Skip adding a habit and go to the dashboard. Verify the new personalised, motivational empty state is shown.

---

## 🚀 How to Run

### Mobile App (Flutter)

```bash
# Get dependencies
flutter pub get

# Run with secrets (required for AI features)
flutter run --dart-define-from-file=secrets.json

# Build debug APK
flutter build apk --debug --dart-define-from-file=secrets.json
```

### Secrets Configuration

Create `secrets.json` in project root:

```json
{
  "DEEPSEEK_API_KEY": "your_deepseek_key",
  "GEMINI_API_KEY": "your_gemini_key",
  "OPENAI_API_KEY": "your_openai_key"
}
```

### Landing Page (React)

```bash
cd landing_page
npm install
npm run dev
```

---

## 🧪 Developer Tools (NEW)

**Phase 27.6** introduced a comprehensive developer tools overlay for testing.

### Access Developer Tools

**Triple-tap** on any screen title (e.g., "AI Coach", "Voice Coach") in debug builds.

### Features

- ✅ **Toggle Premium Mode** (Tier 2) instantly
- ✅ **View AI Status** (tier, availability, kill switches)
- ✅ **Quick Navigation** to any screen
- ✅ **Skip Onboarding** for testing
- ✅ **Copy Debug Info** for bug reports

### Settings Access

All onboarding screens now have a **Settings gear icon** in the top-right corner.  
No need to create a habit first!

---

## 🎨 Customization & Branding

### App Icon

The app icon is **The Pact handshake logo** (blue-to-pink gradient).

**Location:** `android/app/src/main/res/mipmap-*/ic_launcher.png`

To update:
1. Replace icon files in all `mipmap-*` directories
2. Or use `flutter_launcher_icons` package (see docs)

### Branding

- **App Name:** "The Pact"
- **Package:** `co.thepact.app`
- **Domain:** `thepact.co`
- **Colors:** Blue (#00B4D8) to Pink (#FF006E) gradient

---

## 📖 Documentation

### Core Docs
- **[AI_CONTEXT.md](./AI_CONTEXT.md)** - Full feature matrix, architecture deep-dive
- **[ROADMAP.md](./ROADMAP.md)** - Sprint history, current priorities, technical debt

### Setup Guides
- **[GOOGLE_OAUTH_SETUP.md](./docs/GOOGLE_OAUTH_SETUP.md)** - Google Sign-In configuration
- **[APP_ICON_UPDATE_GUIDE.md](./APP_ICON_UPDATE_GUIDE.md)** - Branding update instructions

---

## 🧪 Testing

### Run Unit Tests

```bash
flutter test
```

### Key Test Files

- `test/services/ai/deep_seek_service_test.dart` - AI model integration tests
- `test/services/ai/ai_service_manager_test.dart` - Tier selection logic tests

### Testing Voice Interface

1. Build debug APK: `flutter build apk --debug --dart-define-from-file=secrets.json`
2. Install on device
3. Tap **Settings** (gear icon) → **Developer Settings**
4. Enable **Premium (Tier 2)**
5. Go back → Tap **AI Coach**
6. Should route to **Voice Coach** (no auth required in dev mode)

---

## 🚢 Deployment

### Mobile (Flutter)

```bash
# Android
flutter build appbundle --release --dart-define-from-file=secrets.json

# iOS
flutter build ipa --release --dart-define-from-file=secrets.json
```

### Web (React)

Auto-deployed via Netlify on push to `main` branch.

**Manual deploy:**
```bash
cd landing_page
npm run build
# Upload dist/ to Netlify
```

### Supabase Edge Functions

```bash
# Deploy get-gemini-ephemeral-token function
supabase functions deploy get-gemini-ephemeral-token --project-ref lwzvvaqgvcmsxblcglxo

# Set secrets
supabase secrets set GEMINI_API_KEY=your_key --project-ref lwzvvaqgvcmsxblcglxo
```

---

## 🔧 Troubleshooting

### Voice Interface Not Connecting

1. **Check Dev Mode:** Settings → Developer Settings → Premium (Tier 2) enabled?
2. **Check API Key:** Is `GEMINI_API_KEY` in `secrets.json`?
3. **Check Logs:** Run `flutter run` and watch console for errors
4. **Copy Debug Info:** Triple-tap screen title → Copy Debug Info → Share with team

### Google Sign-In Failing

See **[docs/GOOGLE_OAUTH_SETUP.md](./docs/GOOGLE_OAUTH_SETUP.md)** for full setup guide.

**Quick check:**
- SHA-1 fingerprint matches? Run `cd android && ./gradlew signingReport`
- Google OAuth client configured in Supabase?
- Package name is `co.thepact.app`?

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🙏 Acknowledgments

Built with inspiration from James Clear's *Atomic Habits* and the philosophy of social accountability.

**Phase 27 Voice First Pivot** inspired by the success of voice-first apps like Replika and Character.AI.
