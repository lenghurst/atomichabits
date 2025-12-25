# The Pact

> **"Don't rely on willpower. Rely on your friends."**

A social habit-tracking app that turns personal goals into socially binding contracts.  
Built on **Flutter** (Mobile) with **Voice-First AI Coaching**.

**Live URL:** [thepact.co](https://thepact.co)

---

## 📊 Status

| Component | Status | URL |
|-----------|--------|-----|
| **Mobile App** | 🟢 Phase 34.4 - Debug Diagnostics | _NYE 2025 Target_ |
| **Landing Page** | 🟢 Live | [thepact.co](https://thepact.co) |
| **Backend** | 🟢 Live | Supabase + Edge Functions |
| **Voice AI** | 🟢 Ready for Test | Gemini 3 Live API (Oliver Backdoor Active) |
| **Text AI** | 🔧 Debugging | DeepSeek V3 (API key loading under investigation) |

> **Last Updated:** 25 December 2025 (Commit: Phase 34.4 - Debug Diagnostics)  
> **Current Phase:** Phase 34.4 - Debug Diagnostics + Voice Coach UI  
> **Council Status:** 🟢 GREEN LIGHT FOR LAUNCH  
> **Language:** UK English (Default)

---

## 🧠 The "Council of Five" Architecture (Phase 34)

We have implemented a comprehensive architectural refactoring based on expert review from the "Council of Five" (Martin Fowler, Eric Evans, Robert C. Martin, Casey Muratori, Remi Rousselet).

### Key Architectural Changes

| Pattern | Implementation | Purpose |
|---------|---------------|---------|
| **Repository Pattern** | `lib/data/repositories/` | Decouples persistence from business logic |
| **Domain Providers** | `lib/data/providers/` | Separated state management by domain |
| **PsychometricProfile** | `lib/domain/entities/` | Rich domain entity for AI personalisation |
| **PsychometricEngine** | `lib/domain/services/` | Incremental behavioural analysis |

### New Directory Structure

```
lib/
├── data/
│   ├── repositories/           # Infrastructure Layer (Uncle Bob)
│   │   ├── settings_repository.dart      (Interface)
│   │   ├── hive_settings_repository.dart (Implementation)
│   │   ├── user_repository.dart
│   │   ├── hive_user_repository.dart
│   │   ├── habit_repository.dart
│   │   ├── hive_habit_repository.dart
│   │   ├── psychometric_repository.dart
│   │   └── hive_psychometric_repository.dart
│   │
│   ├── providers/              # State Management Layer (Rousselet)
│   │   ├── settings_provider.dart
│   │   ├── user_provider.dart
│   │   ├── habit_provider.dart
│   │   └── psychometric_provider.dart
│   │
│   └── app_state.dart          # LEGACY: Being strangled
│
├── domain/
│   ├── entities/               # Pure Domain Models (Fowler)
│   │   └── psychometric_profile.dart
│   │
│   └── services/               # Domain Logic (Evans)
│       └── psychometric_engine.dart
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

## 🤖 AI Agent Quick Start

### The "Big Three" Documentation Files

| File | Purpose | When to Update |
|------|---------|----------------|
| **README.md** | Project overview, architecture, user-facing docs | On major features |
| **AI_CONTEXT.md** | Current state checkpoint for AI agents | Every session end |
| **ROADMAP.md** | Priorities, sprint tracking, technical debt | Every session end |

### Mandatory Session Checklist

**Before Starting:**
```
□ 1. Read README.md (project overview, architecture)
□ 2. Read AI_CONTEXT.md (current state, what's implemented)
□ 3. Read ROADMAP.md (what's next, priorities)
□ 4. Read docs/ARCHITECTURE_MIGRATION.md (new provider architecture)
```

**After Completing:**
```
□ 1. SAVE ALL FILES: Ensure no unsaved buffers exist.
□ 2. COMMIT ALL CHANGES: git commit -am "feat/fix: description"
□ 3. PUSH TO REMOTE: git push origin main
□ 4. Update AI_CONTEXT.md with any new features/changes
□ 5. Update ROADMAP.md if priorities changed
```

---

## 🏗️ Architecture: "The Unified Front"

### Voice Architecture

```
User → Voice Coach Screen
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

### PsychometricProfile Architecture (NEW)

```
User Behaviour → PsychometricEngine
                       ↓
              PsychometricProfile
                       ↓
              toSystemPrompt()
                       ↓
              [[USER PSYCHOMETRICS]]
              CORE DRIVERS:
              - Values: Health, Mastery
              - Primary Drive: Become the best version
              - FEARS: The Lazy Stoner
              
              COMMUNICATION PROTOCOL:
              - Adopt Persona: SUPPORTIVE
              - Verbosity Level: 3/5
              
              BEHAVIORAL RISKS:
              - High-Risk Drop-off Zones: Weekends
              - Current Resilience: 70%
                       ↓
              Gemini/DeepSeek LLM
```

---

## 🛠️ Tech Stack

| Component | Technology | Role |
|-----------|------------|------|
| **Mobile** | Flutter 3.38.4 | The Core Experience |
| **Web** | React + Vite + Tailwind | The Landing Page / Redirector |
| **Backend** | Supabase | Auth, Database, Realtime, Edge Functions |
| **AI (Tier 1)** | DeepSeek-V3 | Text reasoning & logic |
| **AI (Tier 2)** | Gemini 3 Flash (2.5 Live) | Real-time voice coaching |
| **Voice** | Gemini Live API | WebSocket audio streaming |
| **Hosting** | Netlify | Web Deployment |

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
1. Long press App Icon → **App Info**
2. Go to **Permissions** → **Microphone**
3. Set to **"Allow only while using the app"**

### Secrets Configuration

Create `secrets.json` in project root:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your_supabase_anon_key",
  "GOOGLE_WEB_CLIENT_ID": "your-web-client-id.apps.googleusercontent.com",
  "DEEPSEEK_API_KEY": "your_deepseek_key",
  "GEMINI_API_KEY": "your_gemini_key",
  "OPENAI_API_KEY": "your_openai_key"
}
```

**Important Notes:**
- `GOOGLE_WEB_CLIENT_ID` must be a **Web** Client ID (not Android) from Google Cloud Console
- The Android Client ID is determined by SHA-1 fingerprint, not this file
- Ensure keys are named exactly as shown. The file is in `.gitignore`.

---

## 📖 Documentation

### Core Docs
- **[AI_CONTEXT.md](./AI_CONTEXT.md)** - Full feature matrix, architecture deep-dive
- **[ROADMAP.md](./ROADMAP.md)** - Sprint history, current priorities, technical debt
- **[docs/ARCHITECTURE_MIGRATION.md](./docs/ARCHITECTURE_MIGRATION.md)** - New provider architecture guide

### Setup Guides
- **[GOOGLE_OAUTH_SETUP.md](./docs/GOOGLE_OAUTH_SETUP.md)** - Google Sign-In configuration
- **[VOICE_COACH_VALIDATION.md](./docs/VOICE_COACH_VALIDATION.md)** - Voice Coach smoke test protocol
- **[APP_ICON_UPDATE_GUIDE.md](./APP_ICON_UPDATE_GUIDE.md)** - Branding update instructions

### Diagnostic Tools
- **[lib/tool/diagnose_google_signin.dart](./lib/tool/diagnose_google_signin.dart)** - SHA-1 diagnostic Flutter app

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

### AI Not Responding (DeepSeek/Gemini)

The app now shows **in-app debug diagnostics** when AI fails. Look for:

```
--- DEBUG INFO ---
API Key Status:
• DeepSeek: ✗ NOT LOADED
• Gemini: ✗ NOT LOADED
```

**If keys show NOT LOADED:**
1. Verify `secrets.json` exists in project root
2. Rebuild with: `flutter build apk --debug --dart-define-from-file=secrets.json`
3. Or pass keys directly:
   ```bash
   flutter build apk --debug \
     --dart-define=DEEPSEEK_API_KEY=your_key \
     --dart-define=GEMINI_API_KEY=your_key
   ```

**Verify secrets.json before building:**
```bash
cat secrets.json | head -10
# Should show DEEPSEEK_API_KEY, GEMINI_API_KEY, etc.
```

### Google Sign-In Failing

See **[docs/GOOGLE_OAUTH_SETUP.md](./docs/GOOGLE_OAUTH_SETUP.md)** for full setup guide.

**Five-Axis Diagnostic:**

| Axis | Check | Command/Location |
|------|-------|------------------|
| 1 | Supabase URL configured | Check `secrets.json` |
| 2 | Web Client ID configured | Check `GOOGLE_WEB_CLIENT_ID` in `secrets.json` |
| 3 | Package name matches | Must be `co.thepact.app` |
| 4 | SHA-1 fingerprint | `cd android && ./gradlew signingReport` |
| 5 | OAuth consent screen | Add test email in Google Cloud Console |

**Configuration Checklist:**

| Location | Field | Value |
|----------|-------|-------|
| **Google Cloud Console** | Web Client redirect URI | `https://your-project.supabase.co/auth/v1/callback` |
| **Google Cloud Console** | Android Client SHA-1 | Your debug keystore SHA-1 |
| **Supabase Dashboard** | Client ID | Web Client ID |
| **Supabase Dashboard** | Client Secret | Web Client Secret |
| **Supabase Dashboard** | Authorised Client IDs | Android Client ID |

---

## 📄 Licence

MIT Licence - See LICENCE file for details

---

## 🙏 Acknowledgements

Built with inspiration from James Clear's *Atomic Habits* and the philosophy of social accountability.

**Phase 27 Voice First Pivot** inspired by the success of voice-first apps like Replika and Character.AI.

**Phase 34 Architecture** guided by the "Council of Five": Martin Fowler, Eric Evans, Robert C. Martin, Casey Muratori, and Remi Rousselet.
