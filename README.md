# The Pact

> **"Don't rely on willpower. Rely on your friends."**

A social habit-tracking app that turns personal goals into socially binding contracts.  
Built on **Flutter** (Mobile) with **Voice-First AI Coaching**.

**Live URL:** [thepact.co](https://thepact.co)

---

## 📊 Status

| Component | Status | URL |
|-----------|--------|-----|
| **Mobile App** | 🟢 Phase 33 - LAUNCH READY | _NYE 2025 Target_ |
| **Landing Page** | 🟢 Live | [thepact.co](https://thepact.co) |
| **Backend** | 🟢 Live | Supabase + Edge Functions |
| **Voice AI** | 🟡 Pending Test | Gemini 3 Live API (Awaiting Final Smoke Test) |

> **Last Updated:** December 24, 2025 (Commit: Phase 33)  
> **Current Phase:** Phase 33 - Brain Surgery 2.5 Complete

---

## 🧠 The "Brain Surgery" Protocol (Phase 33)

We have just completed a critical architectural overhaul ("Brain Surgery 2.5") to close the loop on social accountability.

### Key Changes
1.  **The Pledge (Contract Card):** Before paying, users now see a binding contract card listing their specific habit, witness, and stakes.
2.  **Witness Invite (Share Sheet):** Selecting a witness now triggers a native share sheet (WhatsApp, SMS, etc.) to actually invite them.
3.  **Explicit Auth:** Google Sign-In now explicitly requests `email` and `profile` scopes for trust.
4.  **Voice Coach Polish:** Added sound effects and improved feedback for the AI Coach placeholder.

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
│   │   │   ├── identity_first/           # NEW: The "Pact" Flow
│   │   │   │   ├── value_proposition_screen.dart
│   │   │   │   ├── identity_access_gate_screen.dart
│   │   │   │   ├── witness_investment_screen.dart
│   │   │   │   └── pact_tier_selector_screen.dart
│   │   │   ├── voice_onboarding_screen.dart
│   │   │   └── conversational_onboarding_screen.dart
│   │   └── ...
│   ├── data/
│   │   └── services/
│   │       ├── gemini_live_service.dart
│   │       └── deep_seek_service.dart
│   └── config/
│       └── ai_model_config.dart
├── docs/                 # === DOCUMENTATION ===
│   ├── GOOGLE_OAUTH_SETUP.md
│   └── ...
└── landing_page/         # === REACT WEB ANCHOR ===
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

**Phase 33 has implemented the "Brain Surgery 2.5" recommendations. The final step before launch is a full smoke test.**

### 1. Get New Dependencies

Run `flutter pub get` to install the new contact picker dependencies:

```bash
flutter pub get
```

### 2. Rebuild the Mobile App (APK)

The Flutter app must be rebuilt to include all the new onboarding flows.

```bash
flutter build apk --release --dart-define-from-file=secrets.json
```

### 3. Perform the Final Smoke Test

1. **Test The Pledge:** Verify the "Contract Card" appears on the Tier Selector screen.
2. **Test Witness Invite:** Verify the Share Sheet opens when selecting a witness.
3. **Test Voice Feedback:** Verify the sound effect plays when tapping the AI Coach sample.
4. **Test Google Auth:** Verify the permission dialog requests email/profile access.

---

## 🚀 How to Run

### Mobile App (Flutter)

#### Option A: The "Quick AI Test" (Debug APK)
*Use this to test voice latency and AI response without Supabase Auth (uses direct API key).*

```bash
# Get dependencies
flutter pub get

# Build Debug APK (bypasses auth for AI)
flutter build apk --debug --dart-define-from-file=secrets.json
```
*Output:* `build/app/outputs/flutter-apk/app-debug.apk`

#### Option B: The "Production Reality" (Release APK)
*Use this to test the full user flow including Supabase Auth and Edge Functions.*

```bash
# Build Release APK (requires valid Supabase session)
flutter build apk --release --dart-define-from-file=secrets.json
```
*Output:* `build/app/outputs/flutter-apk/app-release.apk`

#### ⚠️ Xiaomi/MIUI Users
If the app crashes on microphone access or shows "Permission Denied":
1. Long press App Icon -> **App Info**
2. Go to **Permissions** -> **Microphone**
3. Set to **"Allow only while using the app"**

### Secrets Configuration

Create `secrets.json` in project root:

```json
{
  "DEEPSEEK_API_KEY": "your_deepseek_key",
  "GEMINI_API_KEY": "your_gemini_key",
  "OPENAI_API_KEY": "your_openai_key"
}
```

**Note:** Ensure `DEEPSEEK_API_KEY` is named exactly as shown.

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
