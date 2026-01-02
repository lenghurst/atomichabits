# ROADMAP.md — The Pact

> **Last Updated:** 02 January 2026
> **Current Strategy:** The Augmented Constitution (Parallel MVP)
> **Target Launch:** 16 Jan 2026
> **Identity:** Identity Evidence Engine

---

## LOCKED CONFIGURATIONS (Stable)

- **Interactive Model:** `gemini-3-flash-preview` (The Actor)
- **Analysis Model:** `deepseek-chat` (The Analyst)
- **Native Audio:** `gemini-2.5-flash-native-audio-preview-12-2025`
- **TTS Model:** `gemini-2.5-flash-preview-tts` (Lazy Generation)

---

## The Unconventional MVP: 5 Parallel Layers

We are ignoring linear versions (v1, v2). We are building 5 interconnected layers simultaneously.

### Layer 1: The Evidence Engine (Foundation)

**Goal:** Database schema with philosophical integrity + privacy guarantees.

| ID | Task | Status |
|----|------|--------|
| E1 | **Schema Definition**: Create `identity_seeds` table in Supabase. | [ ] |
| E2 | **RLS Policies**: Enforce user-only access (psychometric data is sensitive). | [ ] |
| E3 | **Supabase Repository**: Create `SupabasePsychometricRepository` class. | [ ] |
| E4 | **Hybrid Provider**: Update `PsychometricProvider` to write Hive + Supabase. | [ ] |
| E5 | **Sync-on-Login**: Pull cloud profile on authentication. | [ ] |
| E6 | **Evidence API**: Log observable signals (emotion, tone) + AI-inferred constructs. | [ ] |

### Layer 2: The Shadow & Values Profiler (Onboarding)

**Goal:** Magic Wand Onboarding (Voice-First).

| ID | Task | Status |
|----|------|--------|
| S1 | **Voice Wand**: 3-minute recording capture. | [ ] |
| S2 | **Sherlock Profiler**: Extract Core Values + Shadow Archetype. | [ ] |
| S3 | **Lazy TTS Refactor**: Switch `GeminiVoiceNoteService` to generate audio ONLY on "Play" click (Cost Savings). | [ ] |
| S4 | **Shadow Dialogue**: Logic for "Talk to my [Perfectionist/Rebel] part". | [ ] |

### Layer 3: The Living Garden Visualization (UI)

**Goal:** A responsive ecosystem, not a chart.

| ID | Task | Status |
|----|------|--------|
| G1 | **Rive Integration:** `garden_ecosystem` state machine. | [ ] |
| G2 | **Dynamic Inputs:** Wire `hexis_score`, `shadow_presence`, `season` to Rive controller. | [ ] |
| G3 | **Atmospherics:** Weather effects based on user emotional state. | [ ] |

### Layer 4: The Conversational Command Line (Interaction)

**Goal:** Fast, text/voice hybrid command discovery.

| ID | Task | Status |
|----|------|--------|
| C1 | **Daemon CLI:** Command parsing (`log`, `check`, `gap`, `shadow`). | [ ] |
| C2 | **Voice Interaction**: Enhanced `VoiceCoachScreen` supporting command routing. | [ ] |

### Layer 5: Philosophical Intelligence (The Brain)

**Goal:** Real-time DeepSeek analysis.

| ID | Task | Status |
|----|------|--------|
| P1 | **Gap Analysis Engine:** Detect dissonance between Stated Values and Behavior. | [ ] |
| P2 | **Socratic Generator:** Turn "data" into "questions" (e.g., "Is this a seasonal dormancy?"). | [ ] |

---

## Monetization & Forward Model

**Structure:** Monthly Subscription.
**Currency:** "Credits".

**Consumption Model:**

1. **Conversation Turn** = 1 Credit (Transcription + Gemini 3 Reasoning).
2. **Audio Playback** = +1 Credit (TTS Generation via Lazy Load).
3. **Deep Insight** = 2 Credits (DeepSeek Gap Analysis).

---

## Weekly Build Plan (Parallel Tracks)

### Track A: Database & Evidence Engine

- [ ] Supabase migration: `20260102_identity_seeds.sql`.
- [ ] `SupabasePsychometricRepository` implementation.
- [ ] Dual-write logic in `PsychometricProvider`.

### Track B: Voice Interface (The Actor)

- [ ] **Lazy TTS Implementation**: Refactor `VoiceCoachScreen` Play button.
- [ ] **Shadow Persona Prompting**: Update `PromptFactory` for archetypes.

### Track C: Living Garden & Visualization

- [ ] Rive asset integration.
- [ ] `LivingGarden` widget with state binding.

### Track D: Gap Analysis (The Analyst)

- [ ] `PsychometricProvider` -> `DeepSeekService` pipeline update.
- [ ] Implementation of `GapAnalysisEngine` logic.

### Track E: Integration

- [ ] Connect CLI commands to Evidence Engine.
- [ ] "Dogfooding" build distribution.

### Track F: Social & Protocol Refinements (User Priority)

- [ ] **Witness Investment**: deep dive into "Deep Link" vs "Web Landing" for WhatsApp share.
- [ ] **Betting Logic**: Inverse confidence slider + "Tough Truths AI" fallback.
- [ ] **The Oracle**: Separate `VoiceSessionManager` state + Context Injection from Sherlock.

---

## Phase 63: Psychometric Cloud Sync

**Goal:** Establish hybrid storage (Hive + Supabase) for psychometric data.

| ID | Task | Status |
|----|------|--------|
| 63.1 | Create `identity_seeds` migration with RLS | [ ] |
| 63.2 | Implement `SupabasePsychometricRepository` | [ ] |
| 63.3 | Add dual-write to `PsychometricProvider` | [ ] |
| 63.4 | Sync-on-login logic | [ ] |
| 63.5 | Manual verification (RLS check) | [ ] |

---

## Completed Legacy Phases (Reference)

### Phase 62: Sherlock Protocol Refinement (30 Dec 2025)

**Goal:** Align Sherlock with IFS therapy principles and fix privacy leaks.

- [x] IFS Protocol (Protector Parts)
- [x] Autonomy Gate (User Declaration)
- [x] Privacy Fix (Thread-safe audio cleanup)

### Phase 60: Voice Reliability (Hybrid Stack) (29 Dec 2025)

**Goal:** Fix TTS 400 error and ensure robust audio generation.

- [x] Hybrid Architecture (Reasoning/Mouth split)
- [x] WAV Header Fix (Manual PCM wrapping)

### Phase 59: Unified Low-Latency Audio (SoLoud) (29 Dec 2025)

**Goal:** Deliver ultra-low latency (<50ms) voice interaction using C++ FFI.

- [x] SoLoud Protocol
- [x] Direct Streaming
- [x] Buffer Tuning

### Phase 58: Deferred Intelligence & DeepSeek (29 Dec 2025)

**Goal:** Fix "Reasoning Lock" by moving analysis to post-session DeepSeek pipeline.

- [x] DeepSeek V3 Integration
- [x] Deferred Architecture

### Phase 44: The Investment (26 Dec 2025)

**Goal:** Lock the user's identity by persisting PsychometricProfile.

- [x] `finalizeOnboarding()` implementation
- [x] Profile persistence to Hive

### Phase 42: Soul Capture Onboarding (25 Dec 2025)

**Goal:** Implement the Sherlock Protocol for psychological profiling.

- [x] Tool calling support
- [x] Holy Trinity fields
- [x] Crash recovery (immediate save)

---

## Technical Debt Register

| ID | Description | Priority | Target |
|----|-------------|----------|--------|
| TD1 | `AppState` monolithic (1,642 lines) | Medium | Phase 65+ |
| TD2 | `Habit.dart` has `toJson` | Low | Phase 65 |
| TD3 | No DTO separation | Low | Phase 65 |
| TD4 | `HabitEngine` logic in `AppState` | Medium | Future |

---

## Launch Plan

### Success Metrics (16 Jan 2026 Launch)

| Metric | Target | Status |
|--------|--------|--------|
| **APK builds via GitHub Actions** | Builds successfully | [ ] |
| **Voice connects on device** | < 500ms latency | [ ] |
| **No crashes on user's device** | 0 crashes | [ ] |
| **Share Sheet works** | Functional | [ ] |
| **Voice Coach accessible** | From Dashboard | [x] |
| **Cloud Sync (identity_seeds)** | RLS verified | [ ] |

### Post-Launch Goals (Q1 2026)

| Metric | Target | Status |
|--------|--------|--------|
| Unit test coverage | > 60% | [ ] |
| `AppState` deprecated | 100% | [ ] |
| Domain entities are pure | 100% | [ ] |
