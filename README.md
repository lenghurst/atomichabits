# The Pact

> **"Don't rely on willpower. Rely on your friends."**

A social habit-tracking app that turns personal goals into socially binding contracts.  
Built on **Flutter** (Mobile) with **Voice-First AI Coaching**.

**Live URL:** [thepact.co](https://thepact.co)

---

## 📊 Current Status (December 2025)

| Component | Status | Details |
|-----------|--------|---------|
| **Mobile App** | 🟢 Phase 46.2 | Voice Response Fixed, Debug Triggers Added |
| **Landing Page** | 🟢 Live | [thepact.co](https://thepact.co) |
| **Backend** | 🟢 Live | Supabase + Edge Functions |
| **Voice AI** | ✅ **WORKING** | Gemini 2.5 Flash Native (Audio+Text Modalities) |
| **Text AI** | ⚠️ **Needs Funding** | DeepSeek V3 (account balance empty) |
| **Cloud Sync** | 🟢 **Stable** | Auth Reset & Sign-Out fixed (Phase 45.4) |

> **Last Updated:** 26 December 2025  
> **Current Phase:** Phase 45 - Pre-Launch Fixes  
> **Target:** NYE 2025 Launch  
> **Language:** UK English (Default)

---

## 🎯 The Core Philosophy

Traditional habit apps fail because they rely on **you**.  
**The Pact** relies on **us**.

| Principle | Description |
|-----------|-------------|
| **The Contract** | You don't just "set a goal." You sign a **Pact** with a friend (Witness). |
| **The Wax Seal** | A haptic-heavy, ceremonial UI that makes commitment feel weighty. |
| **The Witness** | Your friend gets notified when you succeed (or fail). |
| **Graceful Consistency** | We measure rolling consistency, not fragile streaks. |
| **Voice First** | Talk to your AI coach like a friend, not a form. |

---

## 🛠️ Tech Stack

| Component | Technology | Role |
|-----------|------------|------|
| **Mobile** | Flutter 3.38.4 | The Core Experience |
| **Web** | React + Vite + Tailwind | The Landing Page |
| **Backend** | Supabase | Auth, Database, Realtime, Edge Functions |
| **AI (Tier 1)** | DeepSeek-V3 | Text reasoning (JSON mode) |
| **AI (Tier 2)** | Gemini 2.5 Flash | Real-time voice coaching |
| **Voice** | OpenAI Realtime | Alternative voice provider |
| **Voice Protocol** | WebSocket (Direct) | Removed Edge Function dependency |
| **Hosting** | Netlify | Web Deployment |

---

## 🚀 Quick Start

### Build the App

**Single Command Pipeline:**
```bash
git pull origin main && flutter clean && flutter pub get && flutter build apk --debug --dart-define-from-file=secrets.json
```

**Output:** `build/app/outputs/flutter-apk/app-debug.apk`

### Secrets Configuration

Create `secrets.json` in project root:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your_supabase_anon_key",
  "GOOGLE_WEB_CLIENT_ID": "your-web-client-id.apps.googleusercontent.com",
  "DEEPSEEK_API_KEY": "your_deepseek_key",
  "GEMINI_API_KEY": "your_gemini_key"
}
```

> **Note:** `secrets.json` is in `.gitignore`. Never commit API keys.

---

## 📖 Documentation

### Core Documentation

| File | Purpose |
|------|---------|
| **[AI_CONTEXT.md](./AI_CONTEXT.md)** | AI assistant context, architecture, feature matrix |
| **[ROADMAP.md](./ROADMAP.md)** | Sprint history, priorities, technical debt |
| **[CHANGELOG.md](./CHANGELOG.md)** | Version history |

### Technical Guides

| Guide | Purpose |
|-------|---------|
| **[docs/BUILD_PIPELINE.md](./docs/BUILD_PIPELINE.md)** | Build commands and pipelines |
| **[docs/VERIFICATION_CHECKLIST.md](./docs/VERIFICATION_CHECKLIST.md)** | Testing the Gemini Live connection |
| **[docs/GOOGLE_OAUTH_SETUP.md](./docs/GOOGLE_OAUTH_SETUP.md)** | Google Sign-In configuration |
| **[docs/ARCHITECTURE_MIGRATION.md](./docs/ARCHITECTURE_MIGRATION.md)** | Provider architecture guide |

### Gemini Live API

| Document | Purpose |
|----------|---------|
| **[docs/PHASE_38_LOG_CONSOLE.md](./docs/PHASE_38_LOG_CONSOLE.md)** | In-App Log Console |
| **[docs/PHASE_37_PRODUCTION_READY.md](./docs/PHASE_37_PRODUCTION_READY.md)** | Production headers fix |
| **[docs/PHASE_36_ERROR_ANALYSIS.md](./docs/PHASE_36_ERROR_ANALYSIS.md)** | 403 Forbidden analysis |
| **[docs/GEMINI_LIVE_API_RESEARCH.md](./docs/GEMINI_LIVE_API_RESEARCH.md)** | API research notes |

---

## 🏗️ Architecture

### Directory Structure

```
lib/
├── config/                 # App configuration
│   ├── ai_model_config.dart    # AI model settings
│   ├── ai_prompts.dart         # Phase 42: Sherlock Protocol prompts
│   ├── ai_tools_config.dart    # Phase 42: Tool schemas for function calling
│   └── router/
│       ├── app_routes.dart     # Route constants (Phase 41)
│       └── app_router.dart     # GoRouter config (Phase 41)
│
├── core/                   # Core utilities
│   └── logging/
│       └── log_buffer.dart     # Centralized logging (Phase 38)
│
├── data/
│   ├── repositories/       # Infrastructure Layer
│   │   ├── settings_repository.dart
│   │   ├── user_repository.dart
│   │   ├── habit_repository.dart
│   │   └── psychometric_repository.dart
│   │
│   ├── providers/          # State Management
│   │   ├── settings_provider.dart
│   │   ├── user_provider.dart
│   │   ├── habit_provider.dart
│   │   └── psychometric_provider.dart
│   │
│   ├── services/           # External Services
│   │   ├── gemini_live_service.dart     # Phase 42: Tool calling support
│   │   ├── audio_recording_service.dart
│   │   ├── voice_session_manager.dart   # Phase 42: Orchestration
│   │   └── ai/
│   │       └── prompt_factory.dart      # Phase 42: Dynamic prompts
│   │
│   └── app_state.dart      # Legacy (being strangled)
│
├── domain/
│   └── services/           # Domain Logic
│       ├── psychometric_engine.dart
│       └── voice_provider_selector.dart # Diagnostics tool (Phase 46)
│
└── features/
    ├── dev/                # Developer Tools
    │   ├── dev_tools_overlay.dart
    │   └── debug_console_view.dart     # Log viewer (Phase 38)
    │
    └── onboarding/         # Onboarding Flow
        └── voice_coach_screen.dart
```

### Voice Architecture (Phase 42: Tool Calling)

```
User → Voice Coach Screen
         ↓
     Voice Session Manager
         ↓
    VoiceApiService (Interface)
    (Gemini / OpenAI)
         ↓
    Direct WebSocket
  (Edge Fn Removed)
         ↓
    AI Provider API
    + Tool Calling Support
         ↓
   ┌─────┴─────┐
   │           │
Audio     tool_call event
   │           │
   │     PsychometricProvider
   │     → Hive (immediate save)
   │           │
   └─────┬─────┘
         ↓
   tool_response → AI continues
```

---

## 🔧 Developer Tools

### Accessing DevTools

**Triple-tap** any screen title to open the Developer Tools overlay.

### Features

| Feature | Status | Notes |
| :--- | :---: | :--- |
| **Premium Toggle** | Enable/disable Tier 2 (Voice) mode |
| **View Logs** | In-App Voice Log Console |
| **Connection Test** | Pings real servers for latency (Phase 46) |
| **B2C MVP** | 🟢 | **Stable** (iOS/Android) |
| **Sherlock (Voice)** | 🟢 | **Active** (Gemini Live v1beta) |
| **Audio Response** | 🟢 | **Fixed** (Universal Parser) |
| **Psychometrics** | 🟡 | Data Layer Ready, Logic in Progress |
| **Orchestrator** | 🔴 | Planned (Q1 2026) |
| **Quick Navigation** | Jump to any screen |

### Debugging Voice Connection

1. Open DevTools (triple-tap)
2. Enable Premium Mode
3. Navigate to Voice Coach
4. Tap microphone to connect
5. Open "View Gemini Logs" to see connection details
6. Copy logs for debugging

---

## 🧪 Testing

### Run Unit Tests

```bash
flutter test
```

### Voice Connection Test

See **[docs/VERIFICATION_CHECKLIST.md](./docs/VERIFICATION_CHECKLIST.md)** for the full testing protocol.

---

## 🚢 Deployment

### Android

```bash
flutter build appbundle --release --dart-define-from-file=secrets.json
```

### iOS

```bash
flutter build ipa --release --dart-define-from-file=secrets.json
```

### Supabase Edge Functions

```bash
supabase functions deploy get-gemini-ephemeral-token --project-ref lwzvvaqgvcmsxblcglxo
supabase secrets set GEMINI_API_KEY=your_key --project-ref lwzvvaqgvcmsxblcglxo
```

---

## 🔧 Troubleshooting

### Voice Not Connecting

1. **Check DevTools:** Is Premium Mode enabled?
2. **Check API Key:** Is `GEMINI_API_KEY` in `secrets.json`?
3. **Check Logs:** Open "View Gemini Logs" in DevTools
4. **Follow Checklist:** See [docs/VERIFICATION_CHECKLIST.md](./docs/VERIFICATION_CHECKLIST.md)

### Google Sign-In Failing

See **[docs/GOOGLE_OAUTH_SETUP.md](./docs/GOOGLE_OAUTH_SETUP.md)** for the full setup guide.

**Quick Checklist:**

| Check | Location |
|-------|----------|
| Supabase URL | `secrets.json` |
| Web Client ID | `secrets.json` |
| Package name | Must be `co.thepact.app` |
| SHA-1 fingerprint | `cd android && ./gradlew signingReport` |
| OAuth consent | Add test email in Google Cloud Console |

---

## 📄 Licence

MIT Licence - See LICENCE file for details

---

## 🙏 Acknowledgements

Built with inspiration from James Clear's *Atomic Habits* and the philosophy of social accountability.

**Architecture** guided by the "Council of Five": Martin Fowler, Eric Evans, Robert C. Martin, Casey Muratori, and Remi Rousselet.

**Voice Integration** powered by Google's Gemini Live API.
