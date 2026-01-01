# ROADMAP.md — The Pact

> **Last Updated:** 01 January 2026  
> **Current Strategy:** The Augmented Constitution (Parallel MVP)  
> **Identity:** Identity Evidence Engine

---

## 🔒 LOCKED CONFIGURATIONS (Stable)
- **Interactive Model:** `gemini-3-flash-preview` (The Actor)
- **Analysis Model:** `deepseek-chat` (The Analyst)
- **Native Audio:** `gemini-2.5-flash-native-audio-preview-12-2025`
- **TTS Model:** `gemini-2.5-flash-preview-tts` (Lazy Generation)

---

## 🎯 The Unconventional MVP: 5 Parallel Layers

We are ignoring linear versions (v1, v2). We are building 5 interconnected layers simultaneously.

### Layer 1: The Evidence Engine (Foundation)
**Goal:** Database schema with philosophical integrity.
- [ ] **Schema Definition** (Supabase): `identity_seeds`, `identity_evidence`, `value_behavior_gaps`.
- [ ] **Evidence API**: Log phenomenological richness (effort, shadow presence, emotion).
- [ ] **Real-time Subscriptions**: Piping updates to the UI.

### Layer 2: The Shadow & Values Profiler (Onboarding)
**Goal:** Magic Wand Onboarding (Voice-First).
- [ ] **Voice Wand**: 3-minute recording capture.
- [ ] **Sherlock Profiler**: Extract Core Values + Shadow Archetype.
- [ ] **Lazy TTS Refactor**: Switch `GeminiVoiceNoteService` to generate audio ONLY on "Play" click (Cost Savings).
- [ ] **Shadow Dialogue**: Logic for "Talk to my [Perfectionist/Rebel] part".

### Layer 3: The Living Garden Visualization (UI)
**Goal:** A responsive ecosystem, not a chart.
- [ ] **Rive Integration:** `garden_ecosystem` state machine.
- [ ] **Dynamic Inputs:** Wire `hexis_score`, `shadow_presence`, `season` to Rive controller.
- [ ] **Atmospherics:** Weather effects based on user emotional state.

### Layer 4: The Conversational Command Line (Interaction)
**Goal:** Fast, text/voice hybrid command discovery.
- [ ] **Daemon CLI:** Command parsing (`log`, `check`, `gap`, `shadow`).
- [ ] **Voice Interaction**: Enhanced `VoiceCoachScreen` supporting command routing.

### Layer 5: Philosophical Intelligence (The Brain)
**Goal:** Real-time DeepSeek analysis.
- [ ] **Gap Analysis Engine:** Detect dissonance between Stated Values and Behavior.
- [ ] **Socratic Generator:** Turn "data" into "questions" (e.g., "Is this a seasonal dormancy?").

---

## 💰 Monetization & Forward Model

**Structure:** Monthly Subscription.
**Currency:** "Credits".

**Consumption Model:**
1.  **Conversation Turn** = 1 Credit (Transcription + Gemini 3 Reasoning).
2.  **Audio Playback** = +1 Credit (TTS Generation via Lazy Load).
3.  **Deep Insight** = 2 Credits (DeepSeek Gap Analysis).

---

## 🗓️ Weekly Build Plan (Parallel Tracks)

### Track A: Database & Evidence Engine
- [ ] Supabase init with `20260101_augmented_constitution.sql`.
- [ ] Evidence Repository implementation.

### Track B: Voice Interface (The Actor)
- [ ] **Lazy TTS Implementation**: Refactor `VoiceCoachScreen` Play button.
- [ ] **Shadow Persona Prompting**: Update `PromptFactory` for archetypes.

### Track C: Living Garden & Visualization
- [ ] Rive asset integration.
- [ ] `LivingGarden` widget with state binding.

### Track D: Gap Analysis (The Analyst)
- [ ] `PsychometricProvider` → `DeepSeekService` pipeline update.
- [ ] Implementation of `GapAnalysisEngine` logic.

### Track E: Integration
- [ ] Connect CLI commands to Evidence Engine.
- [ ] "Dogfooding" build distribution.

---

## ✅ Completed Legacy Phases (Reference)

### Phase 62: Sherlock Protocol Refinement (30 Dec 2025)
**Goal:** Align Sherlock with IFS therapy principles and fix privacy leaks.
- [x] IFS Protocol (Protector Parts)
- [x] Autonomy Gate (User Declaration)

### Phase 60: Voice Reliability (Hybrid Stack) (29 Dec 2025)
**Goal:** Fix TTS 400 error and ensure robust audio generation.
- [x] Hybrid Architecture (Reasoning/Mouth split)
- [x] WAV Header Fix (Manual PCM wrapping)
