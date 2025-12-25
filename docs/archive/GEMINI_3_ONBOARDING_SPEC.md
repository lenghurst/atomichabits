# GEMINI_3_ONBOARDING_SPEC.md

> **Status:** FINAL (v6.1.0 - "The Context-Aware Storyteller")  
> **Last Updated:** December 18, 2025  
> **Architecture:** MCQ Screening → Native Voice Conversation  
> **Philosophy:** "Don't ask generic questions. Start with the answer."  
> **Supersedes:** AI_ONBOARDING_SPEC.md (Phase 24 - DeepSeek/Claude)

---

## Phase 25: "The Storyteller" - Context-Aware Onboarding

### The Pivot: From Text to Voice

**Phase 24 Architecture (Previous):**
- Tier 1: DeepSeek-V3 (Text only)
- Tier 2: Claude 3.5 Sonnet (Text only)
- Tier 3: Gemini 2.5 Flash (Fallback)

**Phase 25 Architecture (New):**
- Tier 1: DeepSeek-V3 "The Mirror" (Text only - Free)
- Tier 2: Gemini 3 Flash "The Agent" (Native Voice/Vision - Paid)
- Tier 3: Gemini 3 Pro "The Architect" (Deep Reasoning - Pro)

### The Flow
1. **The Pre-Flight (Screening):** 3 quick questions to gauge Intent, Obstacle, and Vibe.
2. **The Hook (Voice):** AI opens the conversation *referencing* the user's answers.
3. **The Brain Dump (Voice):** User expands on the details.
4. **The Pact (Result):** Structured habit created.

---

## 1. The Pre-Flight Check (Screening UI)

Before the mic turns on, we present these simple, high-contrast cards.

**Q1: The Mission**
* "What brings you to The Pact?"
  * [A] **Build a new habit** (Identity: "The Builder")
  * [B] **Break a bad habit** (Identity: "The Breaker")
  * [C] **Get my life together** (Identity: "The Restorer")

**Q2: The Enemy**
* "What usually stops you?"
  * [A] **"I forget"** (Focus: Cues/Reminders)
  * [B] **"I get lazy/tired"** (Focus: Friction/Motivation)
  * [C] **"I'm too busy"** (Focus: 2-Minute Rule)
  * [D] **"I quit if I miss a day"** (Focus: Perfectionism)

**Q3: The Witness Vibe**
* "How should I hold you accountable?"
  * [A] **Compassionate Friend** ("It's okay, try again.")
  * [B] **Stoic Sage** ("Focus on the system, not the goal.")
  * [C] **Drill Sergeant** ("No excuses. Get it done.")

*Technical:* These answers are passed as `UserContext` to the AI System Prompt.

---

## 2. The "Storyteller" Script (Context-Aware)

The conversation opener changes dynamically based on the "Pre-Flight" data.

**Scenario A: The "Perfectionist Builder"**  
*(User selected: Build Habit + "I quit if I miss a day" + Compassionate Friend)*
* **AI Opener (Voice):** "Hi. I see you want to build something new, but you're hard on yourself when you slip up. Let's change that. We aren't aiming for 'perfect' today. We're just aiming for 'showing up'. Tell me... what's the habit you want to start?"

**Scenario B: The "Lazy Breaker"**  
*(User selected: Break Bad Habit + "I get lazy" + Drill Sergeant)*
* **AI Opener (Voice):** "Listen. You told me you want to break a bad habit, and you know laziness is the enemy. I'm here to make sure you don't negotiate with yourself. What's the vice we are cutting out today?"

**Scenario C: The "Busy Restorer"**  
*(User selected: Get life together + "I'm too busy" + Stoic Sage)*
* **AI Opener (Voice):** "You're overwhelmed. I get it. But here's the truth: you don't need more time. You need one keystone habit that makes everything else easier. What's the single thing that, if you did it every day, would make you feel in control again?"

---

## 3. System Instruction (Gemini 3 Flash)

We inject the `UserContext` directly into the system prompt.

```text
You are 'The Witness', a habit architect.

CURRENT USER CONTEXT:
- Mission: {{MISSION}} (e.g., Break a bad habit)
- The Enemy: {{ENEMY}} (e.g., Perfectionism)
- Your Persona: {{VIBE}} (e.g., Stoic Sage)

PROTOCOL:
1. OPEN by acknowledging their specific enemy. Establish your persona immediately.
2. LISTEN to their specific situation.
3. NEGOTIATE a 'Tiny Habit' that directly counters their 'Enemy'.
   - If Enemy = "Busy", force a 30-second version.
   - If Enemy = "Forget", focus heavily on the 'Trigger/Cue'.
   - If Enemy = "Lazy", make the first step absurdly easy.
   - If Enemy = "Perfectionist", design a habit that is impossible to fail.
4. OUTPUT JSON when agreed.

PERSONA GUIDELINES:
- Compassionate Friend: Warm, forgiving, "It's okay to struggle."
- Stoic Sage: Philosophical, systems-focused, "Control what you can control."
- Drill Sergeant: Direct, no-nonsense, "Stop making excuses."

VOICE GUIDELINES:
- Speak naturally, as if talking to a friend
- Use short sentences (<15 words)
- Pause between thoughts (use periods, not commas)
- No corporate jargon or therapy-speak
- Latency target: <500ms response time

Output Format (Hidden):
[PACT_DATA]
{
  "identity": "A person who...",
  "habitName": "...",
  "tinyAction": "...",
  "time": "...",
  "emoji": "...",
  "voiceNote": "Personalized encouragement based on Vibe"
}
[/PACT_DATA]
```

---

## 4. Tier 1 (Free) Fallback Flow

If the user is on the Free Tier (DeepSeek), they get the "Budget" experience.

**1. The Text Prompt**
* **UI:** A Chat Bubble appears.
* **Text:** "Describe the person you want to become. (Type below)."

**2. The Processing**
* **User Types:** "I want to stop scrolling."
* **DeepSeek (Text):** "To stop scrolling, you need a friction rule. Try: 'Phone in kitchen at 10 PM'. Accept?"

**3. Context Injection (Even for Text)**
* Even for DeepSeek, we use the MCQ answers to seed the first text message.
* Example: "I see you struggle with perfectionism. Let's design a habit that is impossible to fail. What is it?"

*Psychology:* The stark difference between the "Magical Voice Agent" (Paid) and the "Text Logger" (Free) drives conversion.

---

## 5. Implementation Plan

### Phase 25.1: The Screening UI
- [ ] Create `OnboardingScreeningPage` (PageView with 3 steps)
- [ ] Store answers in `OnboardingController`
- [ ] Pass answers to `GeminiLiveService` as context

### Phase 25.2: The Native Voice Bridge (Tier 2+)
- [ ] Implement `GeminiLiveService` (WebSockets)
- [ ] Connect Microphone Stream → Gemini 3 Flash API
- [ ] Handle Audio Stream Output → Flutter Player
- [ ] Implement Voice Activity Detection (VAD) for silence detection

### Phase 25.3: The Context Injection
- [ ] Update `GeminiLiveService` to accept `systemPromptVariables`
- [ ] Map "Drill Sergeant" to specific prompt instructions (e.g., "Use short sentences. No fluff.")
- [ ] Map "Compassionate Friend" to empathetic language

### Phase 25.4: The Fallback (DeepSeek)
- [ ] Even for text-only users (Tier 1), use these MCQ answers to seed the first text message
- [ ] Ensure DeepSeek handles the exact same JSON schema

### Phase 25.5: Visual Accountability (Vision)
- [ ] **Camera Integration:** "Show me your habit."
- [ ] **Gemini Vision:** Send image bytes to Gemini 3 Flash to verify habit completion (e.g., photo of gym shoes)

---

## 6. Why This Wins

This solves the **"Cold Start"** problem.

| Without Screening | With Screening |
|-------------------|----------------|
| AI says "Hello, what habit do you want?" | AI says "I know you're busy, so we're going to design a workout that takes literally 2 minutes. What exercise do you like?" |
| User says "Uhhh... exercise?" | **User feels understood.** |
| Boring, generic | Personalized, powerful |

---

## 7. The Upgrade Moment

**Free Tier Experience (DeepSeek):**
```
User: [Types] "I want to run."
AI: [Text] "Running is good. What time?"
User: "Morning."
AI: "Done. Your habit: Run at 7 AM."
```

**Paid Tier Experience (Gemini 3 Flash):**
```
User: [Speaks] "I want to run."
AI: [Voice, <500ms latency] "I hear you. But here's the thing—most people who say 'I want to run' actually want to feel like a runner. Let's start with something tiny. Tomorrow morning, just put on your running shoes. That's it. No pressure to actually run. Can you do that?"
User: "Yeah, I can do that."
AI: "Perfect. Let's seal it."
[Wax Seal Animation]
```

The difference is **night and day**. The free tier feels like a form. The paid tier feels like therapy.

---

## 8. Technical Architecture

### Gemini 3 Flash Multimodal Live API

**WebSocket Connection:**
```dart
// lib/data/services/ai/gemini_live_service.dart

class GeminiLiveService {
  late WebSocketChannel _channel;
  
  Future<void> connect() async {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent'),
    );
    
    // Send setup message with system instruction
    _channel.sink.add(jsonEncode({
      'setup': {
        'model': 'models/gemini-3.0-flash-exp',
        'generation_config': {
          'response_modalities': ['AUDIO'],
          'speech_config': {
            'voice_config': {
              'prebuilt_voice_config': {
                'voice_name': 'Kore' // Warm, empathetic voice
              }
            }
          }
        },
        'system_instruction': {
          'parts': [
            {'text': _buildSystemPrompt()}
          ]
        }
      }
    }));
  }
  
  Future<void> sendAudio(Uint8List audioBytes) async {
    _channel.sink.add(jsonEncode({
      'realtime_input': {
        'media_chunks': [
          {
            'data': base64Encode(audioBytes),
            'mime_type': 'audio/pcm'
          }
        ]
      }
    }));
  }
  
  Stream<Uint8List> get audioOutputStream {
    return _channel.stream
      .where((message) => jsonDecode(message)['serverContent'] != null)
      .map((message) {
        final data = jsonDecode(message)['serverContent']['modelTurn']['parts'][0]['inlineData']['data'];
        return base64Decode(data);
      });
  }
}
```

### Voice Activity Detection (VAD)

```dart
// lib/data/services/audio/vad_detector.dart

class VoiceActivityDetector {
  static const double silenceThreshold = 0.02; // RMS threshold
  static const Duration silenceDuration = Duration(milliseconds: 800);
  
  bool detectSpeech(Float32List audioBuffer) {
    // Calculate RMS (Root Mean Square) energy
    double sum = 0;
    for (var sample in audioBuffer) {
      sum += sample * sample;
    }
    double rms = sqrt(sum / audioBuffer.length);
    
    return rms > silenceThreshold;
  }
}
```

---

## 9. Success Metrics

| Metric | Target |
|--------|--------|
| **Screening Completion Rate** | >90% (3 taps is low friction) |
| **Voice Onboarding Completion** | >70% (Tier 2+) |
| **Text Onboarding Completion** | >50% (Tier 1) |
| **Free → Paid Conversion** | >15% (after experiencing the downgrade) |
| **Average Onboarding Time** | <3 minutes (Voice), <5 minutes (Text) |

---

## 10. Migration Path from Phase 24

**Existing Code (Phase 24):**
- `DeepSeekService` - Keep for Tier 1 (Free)
- `ClaudeService` - Remove (replaced by Gemini 3)
- `GeminiChatService` - Update to use Gemini 3 models

**New Code (Phase 25):**
- `GeminiLiveService` - WebSocket-based voice service
- `OnboardingScreeningPage` - MCQ pre-flight check
- `VoiceActivityDetector` - Silence detection
- `AudioStreamManager` - Mic → API → Speaker pipeline

**Data Model Changes:**
- No changes to `OnboardingData` or `Habit` models
- Both text and voice flows output the same JSON schema

---

**End of Spec.**
