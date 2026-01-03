# Architecture Reconciliation: Digital Truth + Emotion Integration

**Date**: January 3, 2026
**Purpose**: Show how Guardian Mode + Emotion Detection fits within The Pact's 5-Layer Architecture

---

## The Pact: 5-Layer Hybrid AI System

From your `AI_CONTEXT.md` and `ROADMAP.md`:

```
Layer 1: Evidence Engine (Storage)
Layer 2: Shadow Profiler (Sherlock Protocol)
Layer 3: Living Garden (Rive Visualization)
Layer 4: Command Line (Voice/Text CLI)
Layer 5: Philosophical Intelligence (DeepSeek Gap Analysis)
```

---

## Where This Integration Fits

### **Layer 1: Evidence Engine** → **ENHANCED**

**Before**:
- Habits stored in Hive + Supabase
- Identity Evidence = habit completions + streaks

**After (with Digital Truth Sensor)**:
- **NEW Evidence Type**: Digital behavior sessions
- Stored alongside habit completions
- Schema update:

```dart
// lib/domain/entities/identity_evidence.dart (UPDATED)
class IdentityEvidence {
  final String evidenceId;
  final DateTime timestamp;
  final EvidenceType type;

  // Existing types
  final HabitCompletion? habitCompletion;
  final StreakMilestone? streakMilestone;

  // NEW: Digital behavior evidence
  final DoomScrollSession? doomScrollSession; // ← NEW
  final EmotionBehaviorPattern? pattern; // ← NEW
}

enum EvidenceType {
  habitCompletion,
  streakMilestone,
  contractCommitment,
  doomScrollDetected, // ← NEW
  emotionPatternDetected, // ← NEW
}
```

**Integration Point**:
```dart
// When Guardian Mode detects doom scrolling:
final evidence = IdentityEvidence(
  evidenceId: uuid.v4(),
  timestamp: DateTime.now(),
  type: EvidenceType.doomScrollDetected,
  doomScrollSession: DoomScrollSession(
    packageName: 'com.tiktok.android',
    duration: Duration(minutes: 12),
    interventionDelivered: true,
  ),
);

// Store in Evidence Engine
await evidenceRepository.save(evidence);
```

---

### **Layer 2: Shadow Profiler** → **VALIDATED**

**Before**:
- Sherlock Protocol uses Gemini to extract archetype
- Based on user's stated beliefs

**After (with OpenAI Emotion)**:
- Sherlock validates stated beliefs against emotion metadata
- Detects inconsistencies (e.g., user says "not afraid" but voice shows fear)

**Integration Point**:
```dart
// lib/data/services/onboarding/sherlock_protocol.dart (UPDATED)
class SherlockProtocol {
  final EmotionStorageService _emotionStorage;

  Future<void> validateAntiIdentity(String statedAntiIdentity) async {
    final emotion = await _emotionStorage.getLatest();

    if (emotion?.primaryEmotion == 'pride' && statedAntiIdentity.contains('loser')) {
      // User says they fear being a loser, but feels proud
      // → Inconsistency detected → Probe deeper
      await _askClarifyingQuestion(
        "You said you fear being a loser, but you sound confident. What's really holding you back?"
      );
    }
  }
}
```

**Value Add**: 30% improvement in archetype accuracy (estimated from emotion validation)

---

### **Layer 3: Living Garden** → **NEW DATA SOURCE**

**Before**:
- Hexis score visualized in Rive animation
- Based on habit completion rate

**After (with Digital Truth + Emotion)**:
- Hexis score accounts for digital behavior
- Garden visualization reflects emotional state

**Integration Point**:
```dart
// lib/domain/services/hexis_calculator.dart (UPDATED)
class HexisCalculator {
  static double calculate({
    required List<HabitCompletion> completions,
    required List<DoomScrollSession> doomScrollSessions, // ← NEW
    required EmotionalContext? emotion, // ← NEW
  }) {
    double score = _baseHexisFromCompletions(completions);

    // Penalize doom scrolling
    final doomScrollPenalty = doomScrollSessions.length * 0.05;
    score -= doomScrollPenalty;

    // Boost for positive emotional state
    if (emotion != null && emotion.primaryEmotion == 'confidence') {
      score += emotion.emotionalIntensity! * 0.1;
    }

    return score.clamp(0.0, 1.0);
  }
}
```

**Rive Animation**:
- Garden "wilts" when doom scrolling detected
- Garden "glows" when positive emotion detected during voice sessions

---

### **Layer 4: Command Line** → **ENHANCED INPUT**

**Before**:
- Voice Coach uses Gemini for text-based insights
- User speaks, AI responds

**After (with OpenAI Emotion)**:
- Voice sessions capture emotion metadata
- AI responds to both content AND affect

**Integration Point**:
```dart
// lib/data/services/voice_session_manager.dart (UPDATED)
Future<void> startSession(VoiceSessionType type) async {
  final provider = VoiceProviderSelector().selectForSession(type);

  if (provider.provider == 'openai') {
    // Emotion-aware session
    final service = OpenAILiveService(
      onEmotionDetected: (emotion) {
        // Adjust conversation based on detected emotion
        if (emotion.primaryEmotion == 'defensiveness') {
          _switchToGentlerTone();
        } else if (emotion.primaryEmotion == 'engagement') {
          _increaseDepthOfQuestions();
        }
      },
    );
  }
}
```

**Value Add**: Voice Coach adapts in real-time to user's emotional state

---

### **Layer 5: Philosophical Intelligence** → **NEW INSIGHTS**

**Before**:
- DeepSeek V3 performs nightly "Gap Analysis"
- Analyzes habit misses and patterns

**After (with Emotion-Behavior Patterns)**:
- Gap Analysis includes emotion-behavior causality
- Identifies root causes of misses

**Integration Point**:
```dart
// lib/data/services/ai/deep_seek_service.dart (UPDATED)
Future<GapAnalysis> analyzeGaps({
  required List<HabitCompletion> completions,
  required List<DoomScrollSession> doomScrollSessions, // ← NEW
  required List<EmotionBehaviorPattern> patterns, // ← NEW
}) async {
  final prompt = """
  Analyze this user's behavior for identity gaps:

  Habit Completions: ${completions.length}/7 this week
  Doom Scroll Sessions: ${doomScrollSessions.length}

  Detected Patterns:
  ${patterns.map((p) => '- ${p.description}').join('\n')}

  Question: What's the REAL obstacle? Not habits, but identity.
  """;

  final response = await deepSeek.generateContent(prompt);

  return GapAnalysis.fromAIResponse(response);
}
```

**Example Output**:
```
Gap Analysis (DeepSeek V3):

"You didn't miss because you were 'too busy.' You doom-scrolled
for 47 minutes on the same day you 'didn't have time' to meditate.

Pattern detected: When anxious (3 times this week), you avoid
meditation and seek dopamine relief through TikTok.

Your real obstacle: You're using distraction to escape the
discomfort that meditation would surface. The Sleepwalker is
protecting you from feeling."
```

**Value Add**: Gap Analysis becomes emotion-aware, addressing root causes

---

## Provider Hierarchy: Complete Integration

### **Existing Providers** (from `main.dart:103-131`)

```
SettingsProvider
UserProvider
HabitProvider
PsychometricProvider
JITAIProvider
```

### **New Providers** (Sprint Implementation)

```
GuardianModeProvider (Phase 1)
EmotionProvider (Phase 2) - or integrate into JITAIProvider
```

### **Data Flow**

```
User Behavior
    │
    ├─→ Voice Session → OpenAI → EmotionProvider → Hive (2hr)
    │                                  │
    │                                  ▼
    └─→ App Usage → Guardian → JITAIProvider ← EmotionalContext
                                  │
                                  ▼
                         Pattern Detector
                                  │
                                  ▼
                         ContextSnapshot
                                  │
                                  ▼
                         JITAI Decision Engine
                                  │
                                  ├─→ Notification
                                  ├─→ Overlay
                                  └─→ Evidence Engine (Layer 1)
```

---

## Broader Codebase: File-Level Integration

### **Existing Files (Modified)**

| File | Changes | Reason |
|------|---------|--------|
| `lib/domain/entities/context_snapshot.dart` | Add `emotion` and `detectedPattern` fields | JITAI needs emotion context |
| `lib/domain/entities/identity_evidence.dart` | Add `doomScrollSession` and `pattern` evidence types | Track digital behavior as evidence |
| `lib/domain/services/vulnerability_opportunity_calculator.dart` | Use emotion boost in V-O calc | Emotional vulnerability affects intervention timing |
| `lib/domain/services/hexis_calculator.dart` | Penalize doom scrolling, reward positive emotion | Hexis reflects full identity, not just habits |
| `lib/data/services/voice_session_manager.dart` | Capture emotion from OpenAI sessions | Store for JITAI access |
| `lib/data/services/ai/deep_seek_service.dart` | Include patterns in Gap Analysis | Root cause analysis |
| `lib/main.dart` | Wire GuardianModeProvider and EmotionStorage | Provide to widget tree |

### **New Files (Created)**

| File | Purpose | Layer |
|------|---------|-------|
| `lib/data/providers/guardian_mode_provider.dart` | Real-time doom scroll detection | Application |
| `lib/domain/entities/emotional_context.dart` | Emotion data structure | Domain |
| `lib/data/services/emotion_storage_service.dart` | Hive persistence for emotions | Infrastructure |
| `lib/domain/services/emotion_behavior_pattern_detector.dart` | Causal pattern detection | Domain |
| `android/.../GuardianModeService.kt` | Foreground service for monitoring | Platform |

---

## Data Persistence Strategy

### **Hive Boxes** (Local Storage)

```
emotions (NEW)
  └── latest_emotion: EmotionalContext (2hr expiry)

identity_evidence (UPDATED)
  └── evidence_[id]: IdentityEvidence
      ├── habitCompletion
      ├── doomScrollSession (NEW)
      └── emotionPattern (NEW)

context_snapshots (NEW - for debugging)
  └── snapshot_[timestamp]: ContextSnapshot
      └── Includes emotion + pattern for audit
```

### **Supabase Tables** (Cloud Sync)

```sql
-- Existing
habits
habit_completions
psychometric_profiles

-- NEW (Optional - for population learning)
emotion_behavior_patterns (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  emotion_trigger TEXT,
  behavior_response TEXT,
  time_lag_minutes INT,
  confidence FLOAT,
  created_at TIMESTAMP
)

-- Privacy: Aggregated only, no raw emotion data
population_pattern_stats (
  archetype TEXT,
  pattern_type TEXT,
  frequency FLOAT,
  avg_duration_increase FLOAT,
  effective_interventions JSONB
)
```

---

## Performance Considerations

### **Battery Impact**

| Component | Baseline | With Guardian Mode | Mitigation |
|-----------|----------|-------------------|------------|
| **App Usage Monitoring** | 0% | 2-3% | Adaptive polling (5s → 30s) |
| **OpenAI Voice Sessions** | 0.5% | 0.5% | No change (already streaming) |
| **Emotion Storage** | 0% | <0.1% | Hive write on emotion capture only |
| **Pattern Detection** | 0% | <0.1% | On-demand (only when JITAI checks) |

**Total**: ~2.5-3.5% daily drain (acceptable for "always-on" protection)

### **Memory Impact**

| Data Structure | Size | Retention |
|----------------|------|-----------|
| EmotionalContext | ~200 bytes | 2 hours |
| DoomScrollSession | ~500 bytes | 30 days |
| EmotionBehaviorPattern | ~300 bytes | 30 days |
| ContextSnapshot (with emotion) | ~2KB | 24 hours (debug only) |

**Total**: ~50KB additional memory footprint per user

---

## Testing Strategy: Integration Points

### **Unit Tests** (Isolated)

```dart
test/unit/emotional_context_test.dart
test/unit/guardian_mode_provider_test.dart
test/unit/pattern_detector_test.dart
```

### **Integration Tests** (Cross-Layer)

```dart
test/integration/emotion_to_jitai_test.dart
  - Emotion captured → ContextSnapshot updated → V-O calc uses it

test/integration/guardian_to_evidence_test.dart
  - Doom scroll detected → Guardian triggers → Evidence stored

test/integration/pattern_to_intervention_test.dart
  - Pattern detected → JITAI references in content → User sees "anxiety loop"
```

### **E2E Tests** (Full Flow)

```dart
test/e2e/guardian_mode_flow_test.dart
  - User opens TikTok → 10 mins pass → Overlay shows → User dismisses → Evidence logged

test/e2e/emotion_pattern_flow_test.dart
  - Voice session (anxiety) → 30 mins later → TikTok opened → Pattern intervention
```

---

## Migration Path (Existing Users)

### **Phase 1: Guardian Mode**

**New Users**: Opt-in during onboarding (after Sherlock)
**Existing Users**: Show "New Feature" card in dashboard

```dart
// In dashboard, show once:
if (!user.hasSeenGuardianModePromo) {
  showDialog(
    title: "Activate Guardian Mode",
    body: "Stop doom scrolling before it starts. Enable real-time protection?",
    actions: [
      "Activate" → requestPermissions() → start Guardian Mode
      "Maybe Later" → dismiss
    ]
  );
}
```

### **Phase 2: Emotion Routing**

**No user action required** - automatically routes Sherlock/Tough Truths to OpenAI.

**Existing users**: Next Tough Truths session uses emotion detection.

### **Phase 3: Pattern Linking**

**Automatic** - happens in background once emotion + digital data exist.

**First pattern detected**: Show dashboard insight card:
```
"Pattern Detected: Anxiety → Doom Scrolling
When you're anxious, you're 3x more likely to doom-scroll.
The app will now intervene earlier when this pattern starts."
```

---

## Rollback Strategy

If issues arise post-deployment:

| Issue | Rollback Action | Recovery |
|-------|----------------|----------|
| **Battery drain > 5%** | Disable Guardian Mode via remote config | Users revert to retrospective tracking |
| **Play Store rejection** | Remove foreground service, keep WorkManager only | Real-time → 15-min delay interventions |
| **Emotion data leakage** | Clear all emotion Hive boxes | No cloud data to clear (local-only) |
| **Pattern false positives** | Raise confidence threshold from 0.7 → 0.85 | Fewer patterns detected |

**Remote Config Flags**:
```dart
guardianModeEnabled: true/false
emotionCaptureEnabled: true/false
patternDetectionEnabled: true/false
```

---

## Summary: How It All Fits

This integration **enhances every layer** of The Pact's architecture:

| Layer | Enhancement |
|-------|-------------|
| **Layer 1: Evidence** | New evidence types (doom scroll, emotion patterns) |
| **Layer 2: Shadow Profiler** | Emotion validates stated beliefs |
| **Layer 3: Living Garden** | Hexis reflects digital behavior + emotion |
| **Layer 4: Command Line** | Voice adapts to detected emotion in real-time |
| **Layer 5: Gap Analysis** | DeepSeek identifies emotion-behavior causality |

**No layer is untouched.** Every component becomes more intelligent.

**Codebase Impact**:
- Providers: 2 new (Guardian, Emotion or integrate into JITAI)
- Entities: 2 new (EmotionalContext, EmotionBehaviorPattern)
- Services: 3 new (GuardianMode, EmotionStorage, PatternDetector)
- Modified files: 7 (ContextSnapshot, Evidence, V-O Calc, Hexis, VoiceSessionManager, DeepSeek, main.dart)

**Total Lines of Code**: ~2,000 (new) + ~500 (modified) = 2,500 LOC

**Sprint Duration**: 7 days (as outlined in SPRINT plan)

**Post-Sprint Value**: Competitive moat that requires 4 components (no competitor has all):
1. ✅ OpenAI emotion metadata
2. ✅ Real-time behavior tracking
3. ✅ JITAI intervention system
4. ✅ Pattern linking

**This is the Strategic Architecture Update that transforms The Pact from habit tracker to emotional intelligence system.**
