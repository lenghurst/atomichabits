# AI_CONTEXT.md — The Pact

> **Last Updated:** 25 December 2025  
> **Current Phase:** Phase 41.2 - Navigation Migration Complete  
> **Identity:** The Pact  
> **Domain:** thepact.co

---

## ⚠️ AI HANDOFF PROTOCOL (READ FIRST!)

### Mandatory Session Start Checklist
```
□ 1. Read README.md (project overview, quick start)
□ 2. Read AI_CONTEXT.md (current state, architecture) ← YOU ARE HERE
□ 3. Read ROADMAP.md (priorities, sprint history)
□ 4. Check CHANGELOG.md for recent changes
```

### Mandatory Session End Checklist
```
□ 1. Commit all changes: git add -A && git commit -m "description"
□ 2. Push to remote: git push origin main
□ 3. Update AI_CONTEXT.md if architecture changed
□ 4. Update ROADMAP.md if priorities changed
□ 5. Update CHANGELOG.md with version entry
```

---

## Project Overview

**The Pact** — A social habit-tracking app that turns personal goals into socially binding contracts.

**Core Philosophy:** `Graceful Consistency > Fragile Streaks`

**Live URL:** [thepact.co](https://thepact.co)

---

## Tech Stack

| Component | Technology | Version |
|-----------|------------|---------|
| **Mobile** | Flutter | 3.38.4 |
| **Web** | React + Vite + Tailwind | Latest |
| **Backend** | Supabase | ^2.8.4 |
| **AI (Tier 1)** | DeepSeek-V3 | Text Chat (JSON mode) |
| **AI (Tier 2)** | Gemini 2.5 Flash | Voice + Text |
| **Voice** | Gemini Live API | WebSocket Streaming |
| **Hosting** | Netlify | Auto-deploy |

---

## Current State: Phase 41.2

### What's Working

| Feature | Status | Notes |
|---------|--------|-------|
| **Text AI (DeepSeek)** | ⚠️ **Needs Funding** | Account balance empty |
| **Voice AI (Gemini)** | ✅ **WORKING** | `gemini-2.5-flash-native-audio-preview-12-2025` confirmed working |
| **In-App Log Console** | ✅ New | DevTools → View Gemini Logs |
| **Google Sign-In** | ✅ Working | OAuth configured |
| **Onboarding Flow** | ✅ Working | Voice-first with fallback |
| **Dashboard** | ✅ Working | Habit tracking |

### Recent Fixes (Phases 35-41)

| Phase | Fix | Status |
|-------|-----|--------|
| **35** | `thinkingConfig` moved inside `generationConfig` | ✅ |
| **36** | `IOWebSocketChannel` with custom headers | ✅ |
| **37** | Honest User-Agent, `await ready`, granular errors | ✅ |
| **38** | In-App Log Console for debugging | ✅ |
| **39** | Logging consolidation, Oliver backdoor removed | ✅ |
| **40** | DeepSeek `response_format: json_object` | ✅ |
| **41** | Router extraction, route constants, redirect logic | ✅ |
| **41.1** | Priority 1 screens migrated to AppRoutes | ✅ |
| **41.2** | All 44 navigation calls migrated to AppRoutes | ✅ |

### Key Files Changed

| File | Changes |
|------|---------|
| `lib/data/services/gemini_live_service.dart` | WebSocket connection with verbose logging |
| `lib/core/logging/log_buffer.dart` | Centralized log storage (NEW) |
| `lib/features/dev/debug_console_view.dart` | Log viewer widget (NEW) |
| `lib/features/dev/dev_tools_overlay.dart` | Added "View Gemini Logs" button, route constants |
| `lib/config/router/app_routes.dart` | Centralised route constants (NEW) |
| `lib/config/router/app_router.dart` | Extracted GoRouter configuration (NEW) |
| `lib/main.dart` | Reduced by ~180 lines (routes extracted) |

---

## Architecture Overview

### Directory Structure

```
lib/
├── config/                     # Configuration
│   ├── ai_model_config.dart        # AI model settings
│   ├── niche_config.dart           # Target niches
│   └── router/                     # Navigation (Phase 41)
│       ├── app_routes.dart             # Route constants
│       └── app_router.dart             # GoRouter config
│
├── core/                       # Core utilities
│   └── logging/
│       └── log_buffer.dart         # Centralized logging
│
├── data/
│   ├── repositories/           # Infrastructure (Repository Pattern)
│   │   ├── settings_repository.dart
│   │   ├── hive_settings_repository.dart
│   │   ├── user_repository.dart
│   │   ├── habit_repository.dart
│   │   └── psychometric_repository.dart
│   │
│   ├── providers/              # State Management (Riverpod-style)
│   │   ├── settings_provider.dart
│   │   ├── user_provider.dart
│   │   ├── habit_provider.dart
│   │   └── psychometric_provider.dart
│   │
│   ├── services/               # External Services
│   │   ├── gemini_live_service.dart    # Voice AI WebSocket
│   │   ├── audio_recording_service.dart
│   │   ├── voice_session_manager.dart
│   │   └── ai_service_manager.dart
│   │
│   └── app_state.dart          # Legacy (being strangled)
│
├── domain/
│   ├── entities/               # Pure Domain Models
│   │   └── psychometric_profile.dart
│   │
│   └── services/               # Domain Logic
│       └── psychometric_engine.dart
│
└── features/
    ├── dev/                    # Developer Tools
    │   ├── dev_tools_overlay.dart
    │   └── debug_console_view.dart
    │
    ├── onboarding/             # Onboarding Flow
    │   ├── voice_coach_screen.dart
    │   └── identity_first/
    │
    └── dashboard/              # Main Dashboard
        └── habit_list_screen.dart
```

### Voice Architecture

```
User → Voice Coach Screen
         ↓
     Voice Session Manager
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
   IOWebSocketChannel.connect()
   + Custom Headers (Phase 37)
         ↓
   Gemini Live API
   (wss://generativelanguage.googleapis.com/ws/...)
         ↓
   Real-time Voice
```

### Logging Architecture (Phase 38)

```
GeminiLiveService._addDebugLog()
         ↓
     LogBuffer.add()
         ↓
     ValueNotifier update
         ↓
     DebugConsoleView (UI)
         ↓
     One-click Copy to Clipboard
```

---

## AI Configuration

### Model Names

| Tier | Model | Status | Use Case |
|------|-------|--------|----------|
| **Tier 1** | `deepseek-chat` | ⚠️ Needs Funding | Text reasoning (JSON mode) |
| **Tier 2** | `gemini-2.5-flash-native-audio-preview-12-2025` | ✅ **WORKING** | Voice coaching |

### WebSocket Endpoint

```
https://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent
```

### Setup Payload Structure

```json
{
  "setup": {
    "model": "models/gemini-2.5-flash-native-audio-preview-12-2025",
    "generationConfig": {
      "responseModalities": ["AUDIO"],
      "speechConfig": {
        "voiceConfig": {
          "prebuiltVoiceConfig": {
            "voiceName": "Aoede"
          }
        }
      },
      "thinkingConfig": {
        "thinkingLevel": "MINIMAL"
      }
    },
    "systemInstruction": {
      "parts": [{ "text": "..." }]
    }
  }
}
```

---

## Developer Tools

### Accessing DevTools

**Triple-tap** any screen title to open the Developer Tools overlay.

### Available Features

| Feature | Description |
|---------|-------------|
| **Premium Toggle** | Enable/disable Tier 2 (Voice) mode |
| **View Gemini Logs** | In-App Log Console |
| **Copy Debug Info** | Copy diagnostic info |
| **Quick Navigation** | Jump to any screen |

### Log Console Usage

1. Open DevTools (triple-tap)
2. Tap "View Gemini Logs" (green button)
3. Trigger a connection (Voice Coach → Microphone)
4. View real-time logs
5. Tap copy icon to copy all logs

---

## Target Niches

| Niche | Identity | Pain Point |
|-------|----------|------------|
| **Writers** | "A Writer" | Consistency in daily writing |
| **Developers** | "An Indie Maker" | Shipping consistently |
| **Fitness** | "A Morning Person" | Workout habits |
| **Language** | "A Polyglot" | Daily practice |
| **Academic** | "A Deep Worker" | Thesis/research focus |

---

## Key Decisions

### Why IOWebSocketChannel?

Dart's default `WebSocketChannel.connect()` doesn't support custom headers. We use `IOWebSocketChannel.connect()` from `package:web_socket_channel/io.dart` to inject:

```dart
headers: {
  'Host': 'generativelanguage.googleapis.com',
  'User-Agent': 'Dart/3.5 (flutter); co.thepact.app/6.0.4',
}
```

### Why LogBuffer?

The In-App Log Console provides:
1. **Visibility** - See exactly what's happening
2. **Debugging** - Copy logs with one click
3. **Persistence** - Logs survive navigation
4. **Real-time** - Updates via ValueNotifier

### Why Honest User-Agent?

Phase 36 used Python client spoofing (`goog-python-genai/0.1.0`). Phase 37 switched to honest headers because:
1. Sustainable long-term
2. Builds trust with WAFs
3. Professional for production

---

## Known Issues

| Issue | Status | Workaround |
|-------|--------|------------|
| 403 Forbidden on WebSocket | ✅ **FIXED** | Confirmed working with correct model |
| Oliver Backdoor | ✅ Removed | Phase 39 |
| AppState monolithic | ⚠️ Tech Debt | Strangler pattern in progress |

---

## Documentation Index

### Core Docs
- `README.md` - Project overview
- `AI_CONTEXT.md` - This file
- `ROADMAP.md` - Sprint history, priorities
- `CHANGELOG.md` - Version history

### Technical Guides
- `docs/BUILD_PIPELINE.md` - Build commands
- `docs/VERIFICATION_CHECKLIST.md` - Testing protocol
- `docs/GOOGLE_OAUTH_SETUP.md` - OAuth configuration
- `docs/ARCHITECTURE_MIGRATION.md` - Provider architecture

### Gemini Live API
- `docs/PHASE_38_LOG_CONSOLE.md` - In-App Log Console
- `docs/PHASE_37_PRODUCTION_READY.md` - Headers fix
- `docs/PHASE_36_ERROR_ANALYSIS.md` - 403 analysis
- `docs/GEMINI_LIVE_API_RESEARCH.md` - API research

---

## Quick Commands

### Build Debug APK
```bash
flutter build apk --debug --dart-define-from-file=secrets.json
```

### Run with Verbose Logging
```bash
flutter run --verbose --dart-define-from-file=secrets.json
```

### Check Git Status
```bash
git status && git log --oneline -5
```

### Deploy Edge Function
```bash
supabase functions deploy get-gemini-ephemeral-token --project-ref lwzvvaqgvcmsxblcglxo
```
