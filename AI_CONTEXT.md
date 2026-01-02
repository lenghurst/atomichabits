# AI_CONTEXT.md — The Pact

> **Last Updated:** 02 January 2026
> **Current Phase:** The Augmented Constitution (Layers 1-5)
> **Identity:** The Pact
> **Domain:** thepact.co
> **Core Concept:** Identity Evidence Engine

---

# AI Context & Architecture

> **STRICT CONFIGURATION LOCKS (DO NOT CHANGE)**
> The following model configurations are **LOCKED** for stability and product definition. Do not modify these without explicit written authorization from the Architecture Lead.
>
> | Component | Model ID | Status | Reason |
> | :--- | :--- | :--- | :--- |
> | **Reasoning** | `gemini-3-flash-preview` | **LOCKED** | Required for "Thinking Level" capabilities. |
> | **Native Audio** | `gemini-2.5-flash-native-audio-preview-12-2025` | **LOCKED** | Validated native audio endpoint for Dec 2025. |
> | **TTS** | `gemini-2.5-flash-preview-tts` | **LOCKED** | Validated low-latency endpoint with "Aoede" voice. |
>
> **VIOLATION OF THESE LOCKS WILL CAUSE CRITICAL REGRESSIONS.**

---

## AI HANDOFF PROTOCOL (READ FIRST!)

### Mandatory Session Start Checklist

```
[ ] 1. Read README.md (project overview, quick start)
[ ] 2. Read AI_CONTEXT.md (current state, architecture) <- YOU ARE HERE
[ ] 3. Read ROADMAP.md (priorities, sprint history)
[ ] 4. Check CHANGELOG.md for recent changes
```

### Mandatory Session End Checklist

```
[ ] 1. Commit all changes: git add -A && git commit -m "description"
[ ] 2. Push to remote: git push origin main
[ ] 3. Update AI_CONTEXT.md if architecture changed
[ ] 4. Update ROADMAP.md if priorities changed
[ ] 5. Update CHANGELOG.md with version entry
```

---

## Project Overview

**The Pact** — An Identity Evidence Engine. The atomic unit is Identity Evidence.

**Core Philosophy:**

> "We are building an app where the Atomic Unit is Identity Evidence. Through Magic Wand Voice Onboarding, the AI constructs a Dynamic Profile of the user's Shadow Archetypes and Core Values. Returning users encounter a Living Garden Visualization and interact via a Conversational Command Line, receiving Socratic Insights derived from real-time Gap Analysis between professed values and behavioral patterns."

**Live URL:** [thepact.co](https://thepact.co)

---

## Tech Stack

| Component | Technology | Version |
|-----------|------------|---------|
| **Mobile** | Flutter | 3.38.4 |
| **Web** | React + Vite + Tailwind | Latest |
| **Backend** | Supabase | ^2.8.4 |
| **Audio Stack** | **SoLoud (FFI) + WebRTC** | **Low Latency + AEC** |
| **AI (Reasoning)** | Gemini 3 Flash | Super-fast reasoning (SDK) |
| **AI (Voice)** | Gemini 2.5 Flash | Native 24kHz Audio (REST) |
| **Text AI** | DeepSeek-V3 | Analysis Pipeline (Funded) |
| **Voice Protocol** | Hybrid (WS + REST) | Optimized for specific task needs |
| **Hosting** | Netlify | Auto-deploy |

---

## The 5-Layer MVP Architecture

### Layer 1: The Evidence Engine (Supabase)

- **Role:** Database Core.
- **Atomic Unit:** `Identity Evidence` (not habits).
- **Structure:** `identity_seeds`, `identity_evidence`, `value_behavior_gaps`.
- **Sync:** `PsychometricRepository` (Hive) -> `identity_seeds` (Supabase) for Analyst access.

### Layer 2: The Shadow & Values Profiler (Onboarding)

- **Role:** Magic Wand Onboarding.
- **Engine:** **Sherlock (Gemini 3 Flash)**.
- **Process:** 3-minute voice recording -> Socratic Dialogue -> Extract Values & Shadow Archetypes.

### Layer 3: The Living Garden Visualization (UI)

- **Role:** Responsive Ecosystem (Not static charts).
- **Engine:** **Rive**.
- **Inputs:** Hexis Score, Shadow Presence, Time of Day, Season.

### Layer 4: The Conversational Command Line (Interaction)

- **Role:** Interface.
- **Engine:** **Voice Note UI (Gemini 2.5 Flash)**.
- **Commands:** `log`, `check`, `gap`, `shadow`, `ritual`.

### Layer 5: Philosophical Intelligence (Gap Analysis)

- **Role:** The Brain.
- **Engine:** **DeepSeek V3** (Async Analysis).
- **Function:** Detects dissonance between Stated Values and Observed Behavior.

---

## Psychometric Data Flow (Phase 63)

### Hybrid Storage Model

```
User Action (Voice/Text)
         |
         v
   PsychometricProvider
         |
    +----+----+
    |         |
    v         v
  Hive     Supabase
(Local)    (Cloud)
    |         |
    |    identity_seeds
    |    (RLS Protected)
    +----+----+
         |
         v
   AI Context Prompt
```

### Data Privacy Contract

| Data Type | Storage | Access |
|-----------|---------|--------|
| Shadow Archetypes | Hive + Supabase | User only (RLS) |
| Failure Patterns | Hive + Supabase | User only (RLS) |
| Sensor Data (HRV, Sleep) | Hive ONLY | Never synced |
| Conversation Transcripts | Hive + Supabase | User only (RLS) |

> **Privacy Rule:** Biometric sensor data (HRV, sleep, screen time) is NEVER synced to cloud. It exists for local AI context only.

### Sync Strategy

1. **Write Path:** Hive first (crash recovery), then async cloud sync.
2. **Read Path:** Cloud on login (restore), Hive for session (speed).
3. **Conflict Resolution:** `lastUpdated` timestamp comparison - newer wins.
4. **Offline Mode:** Full functionality via Hive; queue syncs for reconnect.

---

## Voice Architecture (Hybrid Roles)

### 1. The Actor (Interactive): Gemini 3 Flash

- **Role:** Sherlock, Shadow Archetypes (Rebel, Perfectionist).
- **Interface:** Voice Coach Screen.
- **Capability:** Real-time persona switching, voice synthesis (via Gemini 2.5 TTS).

### 2. The Analyst (Async): DeepSeek V3

- **Role:** Gap Analysis Engine.
- **Interface:** Background Pipeline (`PsychometricProvider`).
- **Capability:** JSON-based extraction of "Deep Insights" and "Value Gaps".

### Voice Note Functionality (Phase 60: Hybrid Stack)

**Status:** Stable (v6.9.5)

To solve the "Reasoning vs. Speed" trade-off, we utilize a **Hybrid Architecture** for Voice Notes/Voice Coach:

1. **The Ear (Transcription)**: `Gemini 1.5 Flash` (via SDK)
   - **Reason:** Extremely fast, low cost, handles audio bytes natively.

2. **The Brain (Reasoning)**: `Gemini 3 Flash` (via SDK)
   - **Reason:** Superior reasoning capabilities, adheres strictly to "Sherlock" persona.
   - **Input:** Receives *both* transcript (text) and audio (multimodal) to detect tone/emotion.

3. **The Mouth (TTS)**: `Gemini 2.5 Flash TTS` (via **REST API**)
   - **Reason:** The Flutter SDK implementation of `responseModalities: ["AUDIO"]` is currently constrained/buggy. We generally bypass it for TTS.
   - **Mechanism:** Direct HTTP POST to `generativelanguage.googleapis.com`.
   - **Critical Constraint:** The API returns **RAW PCM** bytes (24kHz, 16-bit, Mono).

> **CAUTION: DO NOT TOUCH THE WAV HEADER LOGIC IN `gemini_voice_note_service.dart`**
>
> The method `_generateSpeechViaRest` relies on `_pcmBytesToWav` to manually construct a RIFF/WAVE header around the raw PCM bytes.
>
> **Why?** Flutter's audio players (like `flutter_soloud` or native `audioplayers`) cannot guess the format of a raw stream. Without this header, the file is interpreted as noise or silence.
>
> **The Golden Rule:** Always verify `_pcmBytesToWav(audioBytes)` is called before `file.writeAsBytes()`.

---

## The Sherlock Protocol (Phase 42)

AI extracts 3 psychological traits through deduction:

| Trait | Purpose | Example |
|-------|---------|---------|
| **Anti-Identity** | The villain they fear becoming | "The Sleepwalker" |
| **Failure Archetype** | Why their past habits died | PERFECTIONIST, NOVELTY_SEEKER |
| **Resistance Lie** | The excuse they tell themselves | "The Bargain" |

Each trait is saved **immediately** via tool call (crash recovery).

---

## Current State: Phase 62+

### What's Working

| Feature | Status | Notes |
|---------|--------|-------|
| **Text AI (DeepSeek)** | WORKING | **Phase 58**: Post-Session Analysis Pipeline |
| **Voice AI (Gemini)** | WORKING | **Hardware AEC Enforced** (No Echo) |
| **Soul Capture Onboarding** | WORKING | Sherlock Protocol with real-time tool calls |
| **Pact Identity Card** | WORKING | Variable Reward - flip card reveal |
| **Identity Persistence** | WORKING | Phase 44 - Profile locked to Hive on "ENTER THE PACT" |
| **In-App Log Console** | Working | DevTools -> View Gemini Logs |
| **Google Sign-In** | Working | OAuth configured |
| **Onboarding Flow** | Working | Unified: Voice/Manual/Chat -> Reveal -> Dashboard |
| **Dashboard** | Working | Habit tracking |

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
│   │   ├── psychometric_repository.dart      # Abstract interface
│   │   ├── hive_psychometric_repository.dart # Local storage
│   │   └── supabase_psychometric_repository.dart # Cloud sync (Phase 63)
│   │
│   ├── providers/              # State Management (Riverpod-style)
│   │   ├── settings_provider.dart
│   │   ├── user_provider.dart
│   │   ├── habit_provider.dart
│   │   └── psychometric_provider.dart  # Dual-write: Hive + Supabase
│   │
│   ├── services/               # External Services
│   │   ├── voice_api_service.dart      # Interface (Phase 46)
│   │   ├── gemini_live_service.dart    # Gemini implementation
│   │   ├── openai_live_service.dart    # OpenAI implementation (Phase 46)
│   │   ├── audio_recording_service.dart
│   │   ├── voice_session_manager.dart  # Session Orchestration
│   │   ├── stream_voice_player.dart    # Audio Playback (V2)
│   │   └── ai/
│   │       └── prompt_factory.dart     # Dynamic Prompts
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

---

## AI Configuration

### Model Names

| Tier | Model | Status | Use Case |
|------|-------|--------|----------|
| **Tier 1** | `deepseek-chat` | WORKING | Post-Session Analysis |
| **Tier 2** | `gemini-2.5-flash-native-audio-preview-12-2025` | WORKING | Voice coaching |

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
      "responseModalities": ["AUDIO", "TEXT"],
      "speechConfig": {
        "voiceConfig": {
          "prebuiltVoiceConfig": {
            "voiceName": "Kore"
          }
        }
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

### Audio Playback & Buffering (V2 Architecture)

**Phase 46.3 (StreamVoicePlayer Service)**:

- **Centralized Service**: All audio logic moved to `StreamVoicePlayer.dart`.
- **Event-Driven Architecture**: Uses `StreamController<bool>` to expose playback state to UI.
- **Robustness**: Replaced recursive playback loops with `onPlayerComplete.listen()` for stability.
- **Buffering**: Maintains **24,000 byte threshold** (~0.5s) to prevent stutter.
- **Speaker Enforcement**: Centralized `AudioContext` configuration ensures audio plays through speaker on iOS/Android even when the microphone is active (VoIP mode).

### Connection & Security

- **Endpoints**: Uses `v1beta` (required for 2025 preview models).
- **Headers**:
  - `User-Agent`: `Dart/3.0 (flutter); co.thepact.app/1.0.0` (Essential to bypass Google Frontend firewalls).
  - `Host`: `generativelanguage.googleapis.com`.
- **Auth**: Ephemeral Token via Supabase Edge Function (Primary) -> API Key (Dev Fallback).

---

## Logging Architecture (Phase 38)

```
GeminiLiveService._addDebugLog()
         |
         v
     LogBuffer.add()
         |
         v
     ValueNotifier update
         |
         v
     DebugConsoleView (UI)
         |
         v
     One-click Copy to Clipboard
```

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
| 403 Forbidden on WebSocket | **FIXED** | Confirmed working with correct model |
| Oliver Backdoor | Removed | Phase 39 |
| AppState monolithic | Tech Debt | Strangler pattern in progress |

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
- `docs/DEVICE_TESTING.md` - Device testing & Hotfix guide

### Gemini Live API

- `docs/PHASE_38_LOG_CONSOLE.md` - In-App Log Console
- `docs/PHASE_37_PRODUCTION_READY.md` - Headers fix
- `docs/PHASE_36_ERROR_ANALYSIS.md` - 403 analysis
- `docs/GEMINI_LIVE_API_RESEARCH.md` - API research

---

## Quick Commands

### Build Debug APK (Golden Command)

```bash
git pull origin main && flutter clean && flutter pub get && flutter run --debug --dart-define-from-file=secrets.json
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
