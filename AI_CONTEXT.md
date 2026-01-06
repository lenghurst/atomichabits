# AI_CONTEXT.md — The Pact

> **Last Updated:** 05 January 2026
> **Current Phase:** Onboarding Calibration & Auth Repair (Phase 68 Verified)
> **Identity:** The Pact
> **Domain:** thepact.co
> **Core Concept:** Identity Evidence Engine

---

## Active Research (Check Before Implementing)

Before implementing features related to archetypes, JITAI, or behavioral segmentation, check:
- **[docs/CORE/RESEARCH_QUESTIONS.md](./docs/CORE/RESEARCH_QUESTIONS.md)** — Active research tracking

### Current Research Blockers

| Topic | Status | Impact |
|-------|--------|--------|
| Archetype Taxonomy (RQ-001) | IN RESEARCH | Blocks PD-001 decision |
| Intervention Measurement (RQ-002) | DOCUMENTED | Informs dimension selection |

### Intervention Effectiveness (How We Measure Success)

The JITAI system optimizes for **identity evidence**, not task completion:

```
REWARD FUNCTION (0.0 - 1.0):

Identity Evidence (50%)
├── Habit completed 24h:  +0.35
├── Streak maintained:    +0.15
└── Used tiny version:    +0.25

Engagement (30%)
├── Notification opened:  +0.20
├── Took action:          +0.10
└── Dismissed:            -0.10

Async Identity Delta (15%)
└── Identity score change: ±0.15

Penalties
├── Annoyance signal:     -0.40
└── Notification disabled: -0.60
```

**Code:** `jitai_decision_engine.dart:772-838`

---

# AI Context & Architecture

> **⚠️ STRICT CONFIGURATION LOCKS (DO NOT CHANGE)**
> The following model configurations are **LOCKED** for stability and product definition. Do not modify these without explicit written authorization from the Architecture Lead.
>
> | Component | Model ID | Status | Reason |
> | :--- | :--- | :--- | :--- |
> | **Reasoning** | `gemini-3-flash-preview` | **🔒 LOCKED** | Required for "Thinking Level" capabilities. |
> | **Native Audio** | `gemini-2.5-flash-native-audio-preview-12-2025` | **🔒 LOCKED** | Validated native audio endpoint for Dec 2025. |
> | **TTS** | `gemini-2.5-flash-preview-tts` | **🔒 LOCKED** | Validated low-latency endpoint with "Aoede" voice. |
>
> **VIOLATION OF THESE LOCKS WILL CAUSE CRITICAL REGRESSIONS.**

## 1. The "Component Stack" Architecture

## Psychometric Data Flow (Phase 63)

### Hybrid Storage Model

```mermaid
graph TD
    User[User Action (Voice/Text)] --> Provider[PsychometricProvider]
    Provider --> Hive[(Hive Local)]
    Provider --> Supabase[(Supabase Cloud)]
    
    subgraph Data Layer
        Hive -- "Source of Truth (Offline)" --> Provider
        Supabase -- "identity_seeds (RLS)" --> Provider
    end
    
    Provider --> Context[AI Context Prompt]
```

### Data Privacy Contract

| Data Type | Storage | Access |
|-----------|---------|--------|
| Shadow Archetypes | Hive + Supabase | User only (RLS) |
| Failure Patterns | Hive + Supabase | User only (RLS) |
| Sensor Data (HRV, Sleep) | Hive ONLY | Never synced |
| Conversation Transcripts | Hive + Supabase | User only (RLS) |
| Identity Embeddings (RAG) | Supabase (pgvector) | User only (RLS) |

> **Privacy Rule:** Biometric sensor data (HRV, sleep, screen time) is NEVER synced to cloud. It exists for local AI context only.

## ⚠️ AI HANDOFF PROTOCOL (READ FIRST!)

**Full Protocol:** See `docs/CORE/AI_AGENT_PROTOCOL.md` for complete mandatory behaviors.

### Mandatory Session Start Checklist
```
□ 1. Read README.md (project overview, quick start)
□ 2. Read docs/CORE/AI_HANDOVER.md (session context from last agent)
□ 3. Read docs/CORE/PRODUCT_DECISIONS.md (pending decisions — DO NOT implement PENDING items)
□ 4. Read docs/CORE/GLOSSARY.md (terminology definitions)
□ 5. Read docs/CORE/RESEARCH_QUESTIONS.md (active research — check before implementing)
□ 6. Read AI_CONTEXT.md (current state, architecture) ← YOU ARE HERE
□ 7. Check ROADMAP.md for current priorities
```

### Mandatory Session End Checklist
```
□ 1. Update docs/CORE/AI_HANDOVER.md with session summary
□ 2. Update docs/CORE/PRODUCT_DECISIONS.md if decisions made/needed
□ 3. Update docs/CORE/RESEARCH_QUESTIONS.md if research progressed
□ 4. Update docs/CORE/IMPACT_ANALYSIS.md if cascade effects identified
□ 5. Commit all changes with descriptive message
□ 6. Push to remote branch
```

### For External Research (Deep Think, etc.)
```
□ Read docs/CORE/DEEP_THINK_PROMPT_GUIDANCE.md BEFORE writing prompts
□ Use mandatory template structure
□ Process responses with Task Extraction & Deduplication protocol
```

---

## Project Overview

**The Pact** — An Identity Evidence Engine. The atomic unit is Identity Evidence.

**Core Philosophy:**
"We are building an app where the Atomic Unit is Identity Evidence. Through Magic Wand Voice Onboarding, the AI constructs a Dynamic Profile of the user's Shadow Archetypes and Core Values. Returning users encounter a Binary Interface Dashboard (The Bridge for doing + Skill Tree for being) and interact via a Conversational Command Line, receiving Socratic Insights derived from real-time Gap Analysis between professed values and behavioral patterns."

**Note:** The "Living Garden Visualization" mentioned in original vision is aspirational (Layer 3). Currently implemented: Skill Tree (custom-painted tree metaphor).

**Live URL:** [thepact.co](https://thepact.co)

---

## Tech Stack

| Component | Technology | Version |
|-----------|------------|---------|
| **Mobile** | Flutter | 3.38.4 |
| **Web** | React + Vite + Tailwind | Latest |
| **Backend** | Supabase | ^2.8.4 |
| **Audio Stack** | **SoLoud (FFI) + WebRTC** | **Low Latency + AEC** |
| **AI (Reasoning)** | Gemini 3 Flash | ✅ Super-fast reasoning (SDK) |
| **AI (Voice)** | Gemini 2.5 Flash | ✅ Native 24kHz Audio (REST) |
| **Text AI** | DeepSeek-V3 | ✅ Analysis Pipeline (Active) |
| **Voice Protocol** | Hybrid (WS + REST) | Optimized for specific task needs |
| **Hosting** | Netlify | Auto-deploy |

---

## Current State: Phase 62

### What's Working

| Feature | Status | Notes |
|---------|--------|-------|
| **Text AI (DeepSeek)** | ✅ **WORKING** | **Phase 58**: Post-Session Analysis Pipeline |
| **Voice AI (Gemini)** | ✅ **WORKING** | **Hardware AEC Enforced** (No Echo) |
| **Soul Capture Onboarding** | ✅ **WORKING** | Sherlock Protocol with real-time tool calls |
| **Pact Identity Card** | ✅ **WORKING** | Variable Reward - flip card reveal |
| **Identity Persistence** | ✅ **NEW** | Phase 44 - Profile locked to Hive on "ENTER THE PACT" |
| **In-App Log Console** | ✅ Working | DevTools → View Gemini Logs |
| **Google Sign-In** | ✅ Working | OAuth configured |
| **Onboarding Flow** | ✅ Working | Unified: Voice/Manual/Chat → Reveal → Dashboard |
| **Dashboard** | ✅ Working | Habit tracking |

### Recent Fixes (Phases 35-62)

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
| **46** | Voice simplification & OpenAI Integration | ✅ |
| **46.1** | Audit Remediation (Voice Diagnostics + Deprecations) | ✅ |
| **46.3** | Audio Refactor V2: StreamVoicePlayer Service | ✅ |
| **45.3** | Onboarding Flow Unification (Manual/Chat → Reveal) | ✅ |
| **46.2** | iOS Platform Alignment (Podfile & Permissions) | ✅ |
| **45.4** | Onboarding Persistence (Google Sign-In & Factory Reset) | ✅ |
| **47** | VAD Silence Timeout & "Thinking" State | ✅ |
| **47.1** | Adaptive VAD (DC Offset Removal & Dynamic Threshold) | ✅ |
| **47.2** | UI Interruption Logic (User overrides AI) | ✅ |
| **47.3** | AI Filler Phrase Negative Constraints | ✅ |
| **47.4** | **Manual Turn-Taking** (Tap-to-Talk) | ✅ |
| **48** | **Voice Note UI** (Hold-to-Talk / Tap-to-Lock) | ✅ |
| **49** | **Sherlock Screening** (Amnesia Fix / Thinking Mode) | ✅ |
| **50** | **WAV Header Buffering** (Split-chunk protection) | ✅ |
| **50.1** | Config schema alignment (`v1beta` & `generationConfig`) | ✅ |
| **59** | **SoLoud Protocol** (Ultra-Low Latency Audio Payload) | ✅ |
| **60** | **Hybrid Voice Stack** (Gemini 3 Reasoning + REST TTS) | ✅ |
| **60.1** | **WAV Header Fix** (Manual PCM Wrapping for Mobile) | ✅ |
| **62** | **Sherlock Protocol** (IFS Refinement + Privacy Fixes) | ✅ |
| **67** | **Dashboard Redesign** (Binary Interface + RAG) | ✅ |
| **68** | **Onboarding Calibration** (V4 Nav + Auth Repair) | ✅ |
> **Current Phase:** Onboarding Calibration (Phase 68 Complete)  

...

| Phase | Fix | Status |
|-------|-----|--------|
...
| **63** | **Cloud Sync** (Hybrid Storage + Schema Repair) | ✅ |
| **64** | **Cloud Hydration** (Restore from Cloud on separate install) | ✅ |
| **64.1** | **UserProvider Migration** (Strangler Fig Phase 2) | ✅ |
| **65** | **Digital Truth & Emotion** (Guardian Mode + Vulnerability Boost) | ✅ |
| **66** | **Witness & Share** (Deferred Witness + WhatsApp Deep Links) | ✅ |
| **66.1** | **JITAI Foundation** (Bandit Persistence + Hive State Repository) | ✅ |
| **66.2** | **Evidence Foundation** (Layer 1 Logging + Background Worker) | ✅ |
| **67** | **Dashboard Redesign** (Binary Interface: Bridge + Tree) | ✅ |
| **67.1** | **RAG Vector Memory** (Embedding Service + pgvector) | ✅ |
| **68** | **Onboarding Calibration** (V4 Navigation + Auth Schema Fix) | ✅ |

### Key Files Changed (Phase 42-50)

| File | Changes |
|------|---------|
| `lib/features/onboarding/identity_first/identity_access_gate_screen.dart` | Fixed Google Sign-In redirect target |
| `lib/data/services/audio_recording_service.dart` | **REFACTOR:** Hybrid WebRTC/Record Stack |
| `pubspec.yaml` | Added `flutter_webrtc` for Hardware AEC |
| `lib/config/ai_model_config.dart` | Added Component Stack API Keys |
| `lib/data/app_state.dart` | Added Supabase signOut to `clearAllData` |
| `lib/features/onboarding/screens/tier_selection_screen.dart` | Fixed Standard Protocol navigation loop |
| `lib/data/models/user_profile.dart` | Added `isPremium` field (Data Unification) |
| `lib/data/repositories/hive_user_repository.dart` | Migration logic for unified user data |
| `lib/config/ai_tools_config.dart` | Tool schema for `update_user_psychometrics` (NEW) |
| `lib/config/ai_prompts.dart` | Sherlock Protocol prompt (voiceOnboardingSystemPrompt) |
| `lib/domain/entities/psychometric_profile.dart` | Added `isSynced` & `lastUpdated` (Phase 45.2) |
| `lib/data/repositories/psychometric_repository.dart` | Added `markAsSynced()` interface |
| `lib/data/providers/psychometric_provider.dart` | `updateFromToolCall()` + `finalizeOnboarding()` |
| `lib/data/providers/user_provider.dart` | `completeOnboarding()` for state flag |
| `lib/data/services/ai/prompt_factory.dart` | Dynamic prompt generation (NEW) |
| `lib/data/services/voice_api_service.dart` | NEW abstract interface (Phase 46) |
| `lib/data/services/openai_live_service.dart` | NEW OpenAI implementation (Phase 46) |
| `lib/data/services/gemini_live_service.dart` | Refactored to implement interface |
| `lib/domain/services/voice_provider_selector.dart` | Real network diagnostics (Phase 46) |
| `lib/data/services/voice_session_manager.dart` | Restored Sherlock Logic (Phase 59.2) & Integrated Safety Gate (Phase 59.3) |
| `lib/data/services/audio_recording_service.dart` | Added WebRTC Fallback Logic (Phase 59.1) |
| `lib/data/services/stream_voice_player.dart` | Unified Source of Truth + Trace Logging (Phase 59.4) |
| `lib/data/services/witness_deep_link_service.dart` | WhatsApp Invite Logic (Phase 66) |
| `lib/data/services/evidence_service.dart` | Behavioral Logs & Hive Queue (Phase 66.2) |
| `lib/data/providers/jitai_provider.dart` | Bandit Persistence & State Export (Phase 66.1) |
| `lib/data/services/jitai/jitai_background_worker.dart` | Background Intervention Loop (Phase 66.2) |

---

### The 5-Layer MVP Architecture

**Layer 1: The Evidence Engine (Supabase)**
- **Role:** Database Core.
- **Atomic Unit:** `Identity Evidence` (not habits).
- **Structure:** `identity_seeds`, `identity_evidence`, `value_behavior_gaps`.
- **Sync:** `PsychometricRepository` (Hive) ⮕ `identity_seeds` (Supabase) for Analyst access.

**Layer 2: The Shadow & Values Profiler (Onboarding)**
- **Role:** Magic Wand Onboarding.
- **Engine:** **Sherlock (Gemini 3 Flash)**.
- **Process:** 3-minute voice recording → Socratic Dialogue → Extract Values & Shadow Archetypes.

**Layer 3: The Living Garden Visualization (UI)**
- **Role:** Responsive Ecosystem (Not static charts).
- **Engine:** **Rive**.
- **Inputs:** Hexis Score, Shadow Presence, Time of Day, Season.

**Layer 4: The Conversational Command Line (Interaction)**
- **Role:** Interface.
- **Engine:** **Voice Note UI (Gemini 2.5 Flash)**.
- **Commands:** `log`, `check`, `gap`, `shadow`, `ritual`.

**Layer 5: Philosophical Intelligence (Gap Analysis)**
- **Role:** The Brain.
- **Engine:** **DeepSeek V3** (Async Analysis).
- **Function:** Detects dissonance between Stated Values and Observed Behavior.

---

### Voice Architecture (Hybrid Roles)

**1. The Actor (Interactive): Gemini 3 Flash**
- **Role:** Sherlock, Shadow Archetypes (Rebel, Perfectionist).
- **Interface:** Voice Coach Screen.
- **Capability:** Real-time persona switching, voice synthesis (via Gemini 2.5 TTS).

**2. The Analyst (Async): DeepSeek V3**
- **Role:** Gap Analysis Engine.
- **Interface:** Background Pipeline (`PsychometricProvider`).
- **Capability:** JSON-based extraction of "Deep Insights" and "Value Gaps".

### Voice Note Functionality (Phase 60: Hybrid Stack)

**Status:** ✅ Stable (v6.9.5)

To solve the "Reasoning vs. Speed" trade-off, we utilize a **Hybrid Architecture** for Voice Notes/Voice Coach:

1.  **The Ear (Transcription)**: `Gemini 1.5 Flash` (via SDK)
    *   **Reason:** Extremely fast, low cost, handles audio bytes natively.
2.  **The Brain (Reasoning)**: `Gemini 3 Flash` (via SDK)
    *   **Reason:** Superior reasoning capabilities, adheres strictly to "Sherlock" persona.
    *   **Input:** Receives *both* transcript (text) and audio (multimodal) to detect tone/emotion.
3.  **The Mouth (TTS)**: `Gemini 2.5 Flash TTS` (via **REST API**)
    *   **Reason:** The Flutter SDK implementation of `responseModalities: ["AUDIO"]` is currently constrained/buggy. We generally bypass it for TTS.
    *   **Mechanism:** Direct HTTP POST to `generativelanguage.googleapis.com`.
    *   **Critical Constraint:** The API returns **RAW PCM** bytes (24kHz, 16-bit, Mono).

> [!CAUTION]
> **DO NOT TOUCH THE WAV HEADER LOGIC IN `gemini_voice_note_service.dart`**
>
> The method `_generateSpeechViaRest` relies on `_pcmBytesToWav` to manually construct a RIFF/WAVE header around the raw PCM bytes.
>
> **Why?** Flutter's audio players (like `flutter_soloud` or native `audioplayers`) cannot guess the format of a raw stream. Without this header, the file is interpreted as noise or silence.
>
> **The Golden Rule:** Always verify `_pcmBytesToWav(audioBytes)` is called before `file.writeAsBytes()`.

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
| **Tier 1** | `deepseek-chat` | ✅ **WORKING** | Post-Session Analysis |
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
      "responseModalities": ["AUDIO", "TEXT"],
      "speechConfig": {
        "voiceConfig": {
          "prebuiltVoiceConfig": {
            "voiceName": "Kore"
          }
        }
      }
      // REMOVED: thinkingConfig (Not supported in Flash Native 12-2025)
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

### 4.3 Audio Playback & Buffering (V2 Architecture)
**Phase 46.3 (StreamVoicePlayer Service)**:
- **Centralized Service**: All audio logic moved to `StreamVoicePlayer.dart`.
- **Event-Driven Architecture**: Uses `StreamController<bool>` to expose playback state to UI.
- **Robustness**: Replaced recursive playback loops with `onPlayerComplete.listen()` for stability.
- **Buffering**: Maintains **24,000 byte threshold** (~0.5s) to prevent stutter.
- **Speaker Enforcement**: Centralized `AudioContext` configuration ensures audio plays through speaker on iOS/Android even when the microphone is active (VoIP mode).

### 4.4 Connection & Security
- **Endpoints**: Uses `v1beta` (required for 2025 preview models).
- **Headers**:
  - `User-Agent`: `Dart/3.0 (flutter); co.thepact.app/1.0.0` (Essential to bypass Google Frontend firewalls).
  - `Host`: `generativelanguage.googleapis.com`.
- **Auth**: Ephemeral Token via Supabase Edge Function (Primary) -> API Key (Dev Fallback).

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
