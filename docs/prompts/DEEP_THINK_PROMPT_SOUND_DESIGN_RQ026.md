# Deep Think Prompt: Sound Design & Haptic Specification

> **Target Research:** RQ-026
> **Prepared:** 10 January 2026
> **For:** Google Deep Think / Gemini
> **App Name:** The Pact
> **Priority:** MEDIUM — Addresses 0-byte audio placeholder issue

---

## Your Role

You are a **Senior Sound Designer & Haptic UX Specialist** with expertise in:
- Mobile audio engineering (Android AudioTrack, iOS AVAudioPlayer)
- Haptic feedback design (Android VibrationEffect API, iOS Core Haptics)
- Behavioral psychology of sensory feedback in habit formation
- Mobile battery optimization for audio/haptic features

Your approach: Think step-by-step through the sensory experience. Consider the user's emotional state during each interaction, the technical constraints of mobile platforms, and the balance between impact and battery/file-size cost.

---

## Critical Instruction: Android-First Design

Per **CD-017 (Android-First)**, all specifications MUST work on Android without wearables. iOS support is secondary.

```
ANDROID PRIORITY:
├── VibrationEffect API (API 26+) ← Primary haptic target
├── AudioTrack for low-latency audio ← Primary audio target
├── Battery impact < 0.5% per ritual ← Hard constraint
└── No iOS-only features in core spec
```

---

## Mandatory Context: Locked Architecture

### PD-112: Identity Priming Audio Strategy ✅ RESOLVED
- **Decision:** Hybrid approach (stock default + user unlock)
- **Launch:** 4 stock audio loops (<500KB total)
- **User Unlock:** Recorded mantras at Sapling tier (ICS ≥ 1.2)
- **Constraint:** Audio must work offline (no streaming)

### RQ-018: Airlock Protocol & Identity Priming ✅ COMPLETE
- **5-Second Seal:** Press-and-hold completion ritual
- **Haptic Pattern:** `[0, 50, 0, 100, 0, 200]` (ramp pattern)
- **Transition Pairs:** Different intensities for dangerous vs safe transitions
- **Battery Target:** < 5% daily impact for all Airlock features

### RQ-021: Treaty Lifecycle & UX ✅ COMPLETE
- **Ratification Ritual:** 3-second haptic "wax seal" interaction
- **Audio Mentions:**
  - "Clockwork ticking" during countdown
  - "Heavy thud" on completion
  - "Wax seal" metaphor
- **Visual Sync:** Audio must sync with wax-melting animation

### RQ-022: Council Script Generation ✅ COMPLETE
- **Audiobook Pattern:** Single narrator voice (not multi-voice)
- **TTS Provider:** Gemini 2.5 Flash TTS (future, not launch)
- **SSML:** Client-side prosody mapping via SSMLBuilder

### CD-015: 4-State Energy Model ✅ CONFIRMED
- **States:** high_focus, high_physical, social, recovery
- **Sound Design Implication:** Each state needs distinct audio identity

---

## Current Implementation Reality

### What Exists (Red Team Verified)

| Asset | Status | Location |
|-------|--------|----------|
| `complete.mp3` | ❌ 0 bytes | `assets/sounds/` |
| `recover.mp3` | ❌ 0 bytes | `assets/sounds/` |
| `sign.mp3` | ❌ 0 bytes | `assets/sounds/` |
| HapticService | ❌ Not implemented | Needs H-12 |
| AudioService | ⚠️ Wired but empty | Needs content |

### What's Needed

| Feature | Audio | Haptic | Priority |
|---------|-------|--------|----------|
| **5-Second Seal** (Airlock) | 4 state loops | Ramp pattern | CRITICAL |
| **Ratification Ritual** (Treaty) | Clockwork + Thud | Wax seal feel | HIGH |
| **Council Session** (Future) | TTS stream | Pulse on speech | MEDIUM |
| **Habit Completion** | Celebratory chime | Single buzz | LOW |

---

## Research Question: RQ-026 — Sound Design & Haptic Specification

### Core Question
What are the exact audio assets, haptic patterns, and technical specifications needed for The Pact's sensory feedback system?

### Why This Matters
- **Red Team Finding:** All audio files are currently 0 bytes (placeholders)
- **User Experience:** Sensory feedback is proven to increase ritual engagement
- **Android-First:** VibrationEffect API has specific pattern requirements
- **Battery:** Poor audio/haptic implementation kills battery

### The Problem

The app references audio/haptic feedback in multiple places but lacks:
1. Actual audio files (all placeholders are 0 bytes)
2. Haptic pattern specifications compatible with VibrationEffect
3. Sync timing between audio and haptic
4. Battery-conscious implementation strategy

**Concrete Scenario:**
> Marcus completes a 5-Second Seal after transitioning from "high_focus" (Pirate dev work) to "social" (family dinner). The Airlock overlay appears. He presses and holds the Seal button. What does he HEAR? What does he FEEL? When do these sensations occur relative to the visual countdown?

---

## Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| **1** | **5-Second Seal Audio:** What are the exact audio specifications for the 4 energy state loops? | Specify: duration, frequency range, emotional tone, file format, size target per file |
| **2** | **5-Second Seal Haptic:** What VibrationEffect pattern should accompany the Seal? | Provide exact millisecond timings: `[wait, vibrate, wait, vibrate...]` format |
| **3** | **Ratification Ritual Audio:** What sounds create the "clockwork → wax seal → thud" sequence? | Specify timing sync with 3-second countdown, layer breakdown, file format |
| **4** | **Ratification Haptic:** What haptic pattern creates the "wax seal" sensation? | Provide VibrationEffect timings that feel like pressing into wax |
| **5** | **Energy State Audio Identity:** Should each of the 4 energy states have a distinct audio theme? | If yes, describe the sonic characteristics per state. If no, justify. |
| **6** | **Habit Completion Feedback:** What audio/haptic should fire when a habit is completed? | Specify celebratory vs subtle options |
| **7** | **Audio Sourcing Strategy:** Should we use royalty-free libraries, AI generation, or custom composition? | Recommend with cost/quality/time tradeoffs |
| **8** | **Haptic Fallback:** What happens on devices without VibrationEffect support (API < 26)? | Specify degradation strategy |
| **9** | **Battery Budget:** How do we stay under 0.5% battery per ritual? | Provide technical guidelines |
| **10** | **Audio Sync Timing:** How do we ensure audio and haptic fire in sync on Android? | Specify implementation approach |

---

## Anti-Patterns to Avoid

- ❌ **Over-engineering:** Don't propose spatial audio or binaural beats (OVER-ENGINEERED per CD-018)
- ❌ **iOS-first:** Don't specify Core Haptics patterns without VibrationEffect equivalents
- ❌ **Large files:** Don't propose audio files > 150KB each (<500KB total budget)
- ❌ **Streaming audio:** All audio must work offline
- ❌ **User-burdening:** Don't require users to record audio before first use
- ❌ **Generic sounds:** Don't use generic "ding" or "notification" sounds
- ❌ **Ignoring sync:** Don't treat audio and haptic as independent

---

## Architectural Constraints (Hard Requirements)

| Constraint | Rule | Source |
|------------|------|--------|
| **Platform** | Android-first (VibrationEffect API 26+) | CD-017 |
| **Audio Format** | MP3 or OGG (no WAV for size) | File size |
| **Total Audio Budget** | < 500KB for all stock audio | PD-112 |
| **Per-Ritual Battery** | < 0.5% per ritual execution | CD-018 |
| **Offline Support** | All audio must be bundled, not streamed | PD-112 |
| **4 Energy States** | high_focus, high_physical, social, recovery | CD-015 |
| **Haptic API** | VibrationEffect.createWaveform() | Android |

---

## Output Required

### Deliverable 1: Audio Asset Specification Table

| Asset Name | Purpose | Duration | Format | Size Target | Emotional Tone |
|------------|---------|----------|--------|-------------|----------------|
| `seal_focus.mp3` | 5-Second Seal (high_focus) | ... | ... | ... | ... |
| ... | ... | ... | ... | ... | ... |

### Deliverable 2: Haptic Pattern Specification

```kotlin
// 5-Second Seal Haptic Pattern
val sealPattern = longArrayOf(
    0,    // Start immediately
    50,   // Vibrate 50ms
    100,  // Wait 100ms
    ...
)
val sealAmplitudes = intArrayOf(
    0,    // Off
    100,  // Medium
    0,    // Off
    ...
)
```

### Deliverable 3: Audio-Haptic Sync Timeline

```
5-SECOND SEAL TIMELINE:
0.0s ─────── Button pressed
            │ Audio: [state loop] starts
            │ Haptic: Gentle pulse (50ms)
1.0s ─────── Progress 20%
            │ Audio: [continues]
            │ Haptic: Medium pulse (75ms)
...
5.0s ─────── SEAL COMPLETE
            │ Audio: [completion chime]
            │ Haptic: Strong double-pulse (150ms, 50ms gap, 150ms)
```

### Deliverable 4: Ratification Ritual Timeline

```
RATIFICATION RITUAL (3 seconds):
0.0-1.0s ── "Clockwork" phase
            │ Audio: Ticking (mechanical)
            │ Haptic: Rhythmic pulses (tick-tick-tick)
1.0-2.0s ── "Wax melting" phase
            │ Audio: Warm tone rising
            │ Haptic: Continuous low vibration
2.0-3.0s ── "Seal pressed" phase
            │ Audio: Building tension
            │ Haptic: Increasing intensity
3.0s ────── RATIFIED
            │ Audio: Heavy "thud" + resonance
            │ Haptic: Strong single pulse (200ms at max)
```

### Deliverable 5: Audio Sourcing Recommendation

| Option | Cost | Quality | Time | Recommendation |
|--------|------|---------|------|----------------|
| Royalty-free (Freesound, etc.) | Free | Variable | Fast | ... |
| AI-generated (Suno, etc.) | ~$20/mo | Good | Fast | ... |
| Custom composition | $500+ | Best | Slow | ... |

**Recommended Approach:** [Your recommendation with justification]

### Deliverable 6: Confidence Levels

| Specification | Confidence | Rationale |
|---------------|------------|-----------|
| 5-Second Seal audio | HIGH/MEDIUM/LOW | ... |
| Haptic patterns | HIGH/MEDIUM/LOW | ... |
| Battery estimates | HIGH/MEDIUM/LOW | ... |
| Sourcing recommendation | HIGH/MEDIUM/LOW | ... |

---

## Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Implementable** | Can a developer implement this without clarifying questions? |
| **Sized** | Are file sizes explicit and within budget? |
| **Timed** | Are all timings in milliseconds for easy implementation? |
| **Synced** | Is audio-haptic synchronization clearly specified? |
| **Sourced** | Is there a clear path to obtaining these audio files? |
| **Android-First** | Does this work on Android API 26+ without modification? |

---

## Example of Good Output: Haptic Pattern

```kotlin
/**
 * 5-Second Seal Haptic Pattern
 *
 * Design: Progressive intensity that builds to completion.
 * At 5 key moments (1s intervals), haptic pulses increase.
 *
 * Battery: ~0.02% per execution (5 pulses × 50-150ms)
 */
object SealHaptics {
    // Pattern: [delay, vibrate, delay, vibrate, ...]
    val timings = longArrayOf(
        0,     // Start
        50,    // Pulse 1 (gentle)
        950,   // Wait to 1s mark
        75,    // Pulse 2 (medium)
        925,   // Wait to 2s mark
        100,   // Pulse 3 (stronger)
        900,   // Wait to 3s mark
        125,   // Pulse 4 (strong)
        875,   // Wait to 4s mark
        150,   // Pulse 5 (completion - double)
        50,    // Gap
        150    // Second completion pulse
    )

    // Amplitudes: 0 = off, 255 = max
    val amplitudes = intArrayOf(
        0,     // Off (start)
        100,   // Pulse 1
        0,     // Off
        150,   // Pulse 2
        0,     // Off
        180,   // Pulse 3
        0,     // Off
        220,   // Pulse 4
        0,     // Off
        255,   // Pulse 5a (max)
        0,     // Gap
        255    // Pulse 5b (max)
    )

    fun create(): VibrationEffect {
        return VibrationEffect.createWaveform(timings, amplitudes, -1)
    }
}
```

---

## Final Checklist Before Submitting

- [ ] Each sub-question (1-10) has explicit answer
- [ ] All audio files have format, duration, and size specified
- [ ] All haptic patterns use VibrationEffect-compatible format
- [ ] Audio-haptic sync timelines are millisecond-precise
- [ ] Sourcing recommendation has clear next steps
- [ ] Battery estimates are provided
- [ ] Confidence levels stated for each major recommendation
- [ ] All specs work on Android API 26+ without iOS dependencies
- [ ] Total audio budget stays under 500KB

---

*This prompt follows the DEEP_THINK_PROMPT_GUIDANCE.md quality framework.*
