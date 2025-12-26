# AI_CONTEXT.md — The Pact

> **Last Updated:** 26 December 2025  
> **Current Phase:** Phase 45 - Pre-Launch Fixes  
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

## Current State: Phase 44

### What's Working

| Feature | Status | Notes |
|---------|--------|-------|
| **Text AI (DeepSeek)** | ⚠️ **Needs Funding** | Account balance empty |
| **Voice AI (Gemini)** | ✅ **WORKING** | `gemini-2.5-flash-native-audio-preview-12-2025` with tool calling |
| **Soul Capture Onboarding** | ✅ **WORKING** | Sherlock Protocol with real-time tool calls |
| **Pact Identity Card** | ✅ **WORKING** | Variable Reward - flip card reveal |
| **Identity Persistence** | ✅ **NEW** | Phase 44 - Profile locked to Hive on "ENTER THE PACT" |
| **In-App Log Console** | ✅ Working | DevTools → View Gemini Logs |
| **Google Sign-In** | ✅ Working | OAuth configured |
| **Onboarding Flow** | ✅ Working | Voice → Reveal → Dashboard |
| **Dashboard** | ✅ Working | Habit tracking |

### Recent Fixes (Phases 35-45)

| Phase | Fix | Status |
|-------|-----|--------|
| **35** | `thinkingConfig` moved inside `generationConfig` | ✅ |
| **36** | `IOWebSocketChannel` with custom headers | ✅ |
| **37** | Honest User-Agent, `await ready`, granular errors | ✅ |
| **38** | In-App Log Console for debugging | ✅ |
| **39** | Logging consolidation, Oliver backdoor removed | ✅ |
| **40** | DeepSeek `response_format: json_object` | ✅ |
| **41** | Router extraction, route constants, redirect logic | ✅ |
| **41.2** | All 44 navigation calls migrated to AppRoutes | ✅ |
| **42** | Soul Capture Onboarding with Sherlock Protocol | ✅ |
| **43** | Pact Identity Card (Variable Reward) | ✅ |
| **44** | The Investment - Profile persistence to Hive | ✅ |
| **45.1** | User Data Unification (`isPremium` → `UserProfile`) | ✅ |
| **45.2** | Cloud Sync Prep (`isSynced` flag for Psychometrics) | ✅ |

### Key Files Changed (Phase 42-45)

| File | Changes |
|------|---------|
| `lib/data/models/user_profile.dart` | Added `isPremium` field (Data Unification) |
| `lib/data/repositories/hive_user_repository.dart` | Migration logic for unified user data |
| `lib/config/ai_tools_config.dart` | Tool schema for `update_user_psychometrics` (NEW) |
| `lib/config/ai_prompts.dart` | Sherlock Protocol prompt (voiceOnboardingSystemPrompt) |
| `lib/domain/entities/psychometric_profile.dart` | Added `isSynced` & `lastUpdated` (Phase 45.2) |
| `lib/data/repositories/psychometric_repository.dart` | Added `markAsSynced()` interface |
| `lib/data/providers/psychometric_provider.dart` | `updateFromToolCall()` + `finalizeOnboarding()` |
| `lib/data/providers/user_provider.dart` | `completeOnboarding()` for state flag |
| `lib/data/services/ai/prompt_factory.dart` | Dynamic prompt generation (NEW) |
| `lib/data/services/gemini_live_service.dart` | Tool calling support, `sendToolResponse()` |
| `lib/data/services/voice_session_manager.dart` | `VoiceSessionMode`, orchestration |
| `lib/features/onboarding/widgets/pact_identity_card.dart` | 3D flip card (NEW) |
| `lib/features/onboarding/pact_reveal_screen.dart` | Reveal sequence + Investment wiring |
| `lib/features/onboarding/voice_coach_screen.dart` | "DONE" button, reveal navigation |

---

## Architecture Overview

### Directory Structure

```
lib/
├── config/                     # Configuration
│   ├── ai_model_config.dart        # AI model settings
│   ├── ai_prompts.dart             # Sherlock Protocol prompts (Phase 42)
│   ├── ai_tools_config.dart        # Tool schemas (Phase 42)
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
│   │   ├── gemini_live_service.dart    # Voice AI + Tool Calling (Phase 42)
│   │   ├── audio_recording_service.dart
│   │   ├── voice_session_manager.dart  # Session Orchestration (Phase 42)
│   │   ├── ai_service_manager.dart
│   │   └── ai/
│   │       └── prompt_factory.dart     # Dynamic Prompts (Phase 42)
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

### Voice Architecture (Phase 42: Tool Calling)

```
User → Voice Coach Screen
         ↓
     Voice Session Manager
     (mode: onboarding / coaching)
         ↓
     Gemini Live Service
     (tools: AiToolsConfig.psychometricTool)
         ↓
   ┌─────┴─────┐
   │           │
Supabase    DEV MODE
Edge Fn     (Direct API)
   │           │
   └─────┬─────┘
         ↓
   IOWebSocketChannel.connect()
   + Custom Headers (Phase 37)
         ↓
   Gemini Live API (WebSocket)
         ↓
   ┌─────┴─────────────────┐
   │                       │
Audio/Transcription    tool_call event
   │                       │
   │              PsychometricProvider
   │              .updateFromToolCall()
   │                       │
   │              Hive (immediate save)
   │                       │
   └─────┬─────────────────┘
         ↓
   sendToolResponse() → AI continues
```

### The Sherlock Protocol (Phase 42)

AI extracts 3 psychological traits through deduction:

| Trait | Purpose | Example |
|-------|---------|---------|
| **Anti-Identity** | The villain they fear becoming | "The Sleepwalker" |
| **Failure Archetype** | Why their past habits died | PERFECTIONIST, NOVELTY_SEEKER |
| **Resistance Lie** | The excuse they tell themselves | "The Bargain" |

Each trait is saved **immediately** via tool call (crash recovery).

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
