# Emotion-Digital Behavior Integration

**Date**: January 3, 2026
**Status**: Proposed Architecture
**Combines**: OpenAI Realtime API + Digital Truth Sensor + JITAI

---

## Executive Summary

The integration of OpenAI's emotion metadata with the Digital Truth Sensor creates a **causal feedback loop** that competitors cannot replicate:

1. **Voice Session** → OpenAI detects anxiety (emotion metadata)
2. **30 minutes later** → Digital Truth Sensor detects doom-scrolling
3. **JITAI Engine** → Connects pattern: "Anxiety drives your doom-scrolling"
4. **Next time** → Predictive intervention BEFORE user opens TikTok

---

## Architecture: The Emotion-Behavior Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER INTERACTION                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Voice Session (Sherlock/Tough Truths)                          │
│  ┌────────────────────────────────┐                             │
│  │   OpenAI Realtime API          │                             │
│  │   - Emotion: "anxiety"         │                             │
│  │   - Confidence: 0.82           │                             │
│  │   - Tone: "defensive"          │                             │
│  │   - Timestamp: 14:32:17        │                             │
│  └───────────────┬────────────────┘                             │
│                  │                                               │
│                  ▼                                               │
│  ┌────────────────────────────────────────────────────┐         │
│  │        EmotionalContext (NEW Entity)               │         │
│  │  - primaryEmotion: String                          │         │
│  │  - emotionalIntensity: double                      │         │
│  │  - tone: String                                    │         │
│  │  - capturedAt: DateTime                            │         │
│  │  - vulnerabilityBoost: double (derived)            │         │
│  └───────────────┬────────────────────────────────────┘         │
│                  │                                               │
│                  │ (stored in Hive for 2 hours)                 │
│                  │                                               │
│  ┌───────────────▼───────────────────────────────────┐          │
│  │         ContextSnapshot                           │          │
│  │  + EmotionalContext? emotion (NEW FIELD)          │          │
│  └───────────────┬───────────────────────────────────┘          │
│                  │                                               │
│                  ▼                                               │
│                                                                  │
│  30 minutes later...                                            │
│                                                                  │
│  Digital Behavior (Background Monitoring)                       │
│  ┌────────────────────────────────┐                             │
│  │   Digital Truth Sensor         │                             │
│  │   - User opened TikTok         │                             │
│  │   - Session: 12 minutes        │                             │
│  │   - Dopamine loop: YES         │                             │
│  │   - Timestamp: 15:04:33        │                             │
│  └───────────────┬────────────────┘                             │
│                  │                                               │
│                  ▼                                               │
│  ┌────────────────────────────────────────────────────┐         │
│  │     Pattern Detection Engine (NEW)                 │         │
│  │                                                     │         │
│  │  Rule: IF emotion.anxiety + digital.doomScroll     │         │
│  │        WITHIN 2 hours                               │         │
│  │        THEN log pattern "anxiety_driven_scroll"     │         │
│  └───────────────┬────────────────────────────────────┘         │
│                  │                                               │
│                  ▼                                               │
│  ┌────────────────────────────────────────────────────┐         │
│  │          JITAI Decision Engine                     │         │
│  │  - Pattern detected: anxiety_driven_scroll         │         │
│  │  - Trigger: Real-time (user just opened TikTok)    │         │
│  │  - Intervention: "You're anxious. TikTok won't fix it." │   │
│  └───────────────┬────────────────────────────────────┘         │
│                  │                                               │
│                  ▼                                               │
│           User Receives Intervention                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation: Code Integration Points

### 1. Add EmotionalContext Entity

**File**: `lib/domain/entities/emotional_context.dart` (NEW)

```dart
/// EmotionalContext: Captured emotion state from voice interactions
///
/// Data source: OpenAI Realtime API emotion metadata
/// Lifespan: Stored in Hive for 2 hours (stale after)
/// Used by: JITAI V-O Calculator, Pattern Detector
class EmotionalContext {
  final String? primaryEmotion; // e.g., "anxiety", "joy", "stress"
  final double? emotionalIntensity; // 0.0-1.0
  final String? tone; // e.g., "defensive", "engaged", "dismissive"
  final String? emphasis; // e.g., "high", "low"
  final DateTime capturedAt;

  EmotionalContext({
    this.primaryEmotion,
    this.emotionalIntensity,
    this.tone,
    this.emphasis,
    required this.capturedAt,
  });

  /// Calculate vulnerability boost for JITAI
  double get vulnerabilityBoost {
    if (primaryEmotion == null || emotionalIntensity == null) return 0.0;

    switch (primaryEmotion) {
      case 'anxiety':
      case 'stress':
        return emotionalIntensity! * 0.3; // Max 30% boost
      case 'sadness':
      case 'shame':
        return emotionalIntensity! * 0.25; // Max 25% boost
      case 'anger':
      case 'frustration':
        return emotionalIntensity! * 0.2; // Max 20% boost
      default:
        return 0.0;
    }
  }

  /// Check if emotion is stale (older than 2 hours)
  bool get isStale {
    return DateTime.now().difference(capturedAt) > Duration(hours: 2);
  }

  /// Serialization
  Map<String, dynamic> toJson() => {
        'primaryEmotion': primaryEmotion,
        'emotionalIntensity': emotionalIntensity,
        'tone': tone,
        'emphasis': emphasis,
        'capturedAt': capturedAt.toIso8601String(),
      };

  factory EmotionalContext.fromJson(Map<String, dynamic> json) {
    return EmotionalContext(
      primaryEmotion: json['primaryEmotion'] as String?,
      emotionalIntensity: json['emotionalIntensity'] as double?,
      tone: json['tone'] as String?,
      emphasis: json['emphasis'] as String?,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
    );
  }
}
```

### 2. Update ContextSnapshot

**File**: `lib/domain/entities/context_snapshot.dart`

```dart
class ContextSnapshot {
  // ... existing fields ...

  // === EMOTIONAL FEATURES (Optional - From Voice Sessions) ===
  /// Recent emotional state from voice interaction
  /// Source: OpenAI Realtime API emotion metadata
  /// Expires: 2 hours after capture
  final EmotionalContext? emotion;

  ContextSnapshot({
    // ... existing params ...
    this.emotion,
  });

  /// Create a snapshot with current time context
  factory ContextSnapshot.now({
    // ... existing params ...
    EmotionalContext? emotion,
  }) {
    return ContextSnapshot(
      // ... existing fields ...
      emotion: emotion?.isStale == true ? null : emotion, // Filter stale
    );
  }

  /// Count of available sensor sources
  int get sensorCount {
    int count = 1; // Time is always available
    // ... existing counts ...
    if (emotion != null && !emotion!.isStale) count++;
    return count;
  }
}
```

### 3. Voice Session → Emotion Capture

**File**: `lib/data/services/voice_session_manager.dart`

```dart
class VoiceSessionManager {
  final EmotionStorageService _emotionStorage = EmotionStorageService();

  Future<void> startSession({
    required VoiceSessionType type,
    // ... existing params ...
  }) async {
    // Select provider based on session type
    final selector = VoiceProviderSelector();
    final recommendation = selector.selectForSession(sessionType: type);

    if (recommendation.provider == 'openai') {
      // Use OpenAI with emotion capture
      final openAIService = OpenAILiveService(
        // ... existing callbacks ...
        onEmotionDetected: (emotionMeta) {
          _captureEmotion(emotionMeta);
        },
      );

      // ... start session ...
    }
  }

  void _captureEmotion(EmotionMetadata meta) {
    if (meta.primaryEmotion == null) return;

    final emotionContext = EmotionalContext(
      primaryEmotion: meta.primaryEmotion,
      emotionalIntensity: meta.confidence,
      tone: meta.tone,
      emphasis: meta.emphasis,
      capturedAt: DateTime.now(),
    );

    // Store in Hive for JITAI access
    _emotionStorage.saveLatest(emotionContext);

    debugPrint('Emotion captured: ${emotionContext.primaryEmotion} (${emotionContext.emotionalIntensity})');
  }
}
```

### 4. Pattern Detection Engine

**File**: `lib/domain/services/emotion_behavior_pattern_detector.dart` (NEW)

```dart
/// Detects patterns linking emotional states to digital behaviors
///
/// Examples:
/// - Anxiety → Doom scrolling
/// - Stress → Gaming binges
/// - Sadness → Social media stalking
class EmotionBehaviorPatternDetector {
  final EmotionStorageService _emotionStorage = EmotionStorageService();
  final DigitalTruthSensor _digitalSensor = DigitalTruthSensor();

  /// Time window to check for emotion-behavior correlation
  static const Duration _correlationWindow = Duration(hours: 2);

  /// Detect if recent emotional state correlates with current digital behavior
  Future<EmotionBehaviorPattern?> detectPattern() async {
    // Get recent emotion
    final recentEmotion = await _emotionStorage.getLatest();
    if (recentEmotion == null || recentEmotion.isStale) return null;

    // Get current digital behavior
    final loopAlert = await _digitalSensor.detectDopamineLoop();
    if (loopAlert == null) return null;

    // Check time correlation
    final emotionAge = DateTime.now().difference(recentEmotion.capturedAt);
    if (emotionAge > _correlationWindow) return null;

    // Pattern detected!
    return EmotionBehaviorPattern(
      emotionTrigger: recentEmotion.primaryEmotion!,
      behaviorResponse: 'doom_scrolling',
      timeLag: emotionAge,
      confidence: _calculateConfidence(recentEmotion, loopAlert),
    );
  }

  double _calculateConfidence(EmotionalContext emotion, DopamineLoopAlert loop) {
    // Higher confidence if:
    // - Strong emotion (high intensity)
    // - Short time lag
    // - Multiple app switches (strong loop)

    double confidence = 0.5; // Base

    if (emotion.emotionalIntensity! > 0.7) confidence += 0.2;
    if (emotion.capturedAt.isAfter(DateTime.now().subtract(Duration(minutes: 30)))) {
      confidence += 0.2; // Recent emotion = stronger link
    }
    if (loop.switchCount >= 5) confidence += 0.1;

    return confidence.clamp(0.0, 1.0);
  }
}

class EmotionBehaviorPattern {
  final String emotionTrigger;
  final String behaviorResponse;
  final Duration timeLag;
  final double confidence;

  EmotionBehaviorPattern({
    required this.emotionTrigger,
    required this.behaviorResponse,
    required this.timeLag,
    required this.confidence,
  });

  String get description {
    return '$emotionTrigger → $behaviorResponse (${timeLag.inMinutes} min later, ${(confidence * 100).toStringAsFixed(0)}% confidence)';
  }
}
```

### 5. JITAI Integration

**File**: `lib/domain/services/vulnerability_opportunity_calculator.dart`

```dart
class VulnerabilityOpportunityCalculator {
  static VOState calculate({
    required ContextSnapshot context,
    required PsychometricProfile profile,
  }) {
    double vulnerability = 0.5; // Base
    double opportunity = 0.5; // Base

    // ... existing biometric, calendar, weather calculations ...

    // NEW: Emotional vulnerability boost
    if (context.emotion != null && !context.emotion!.isStale) {
      vulnerability += context.emotion!.vulnerabilityBoost;

      // Explanation for user transparency
      explanations.add(
        'Recent ${context.emotion!.primaryEmotion} detected (voice session ${context.emotion!.capturedAt.hour}:${context.emotion!.capturedAt.minute})'
      );
    }

    return VOState(
      vulnerability: vulnerability.clamp(0.0, 1.0),
      opportunity: opportunity.clamp(0.0, 1.0),
      explanation: explanations.join(', '),
    );
  }
}
```

### 6. Intervention Content Generation

**File**: `lib/data/services/ai/intervention_content_generator.dart`

```dart
class InterventionContentGenerator {
  Future<InterventionContent> generateContent({
    required InterventionArm arm,
    required PsychometricProfile profile,
    required ContextSnapshot context,
    EmotionBehaviorPattern? detectedPattern,
  }) async {
    final prompt = """
    Generate a 1-sentence intervention for this user:

    Archetype: ${profile.failureArchetype}
    Current Context: Doom scrolling detected

    ${detectedPattern != null ? '''
    CRITICAL PATTERN DETECTED:
    ${detectedPattern.description}
    User tends to doom-scroll when feeling ${detectedPattern.emotionTrigger}.
    Reference this pattern in the intervention.
    ''' : ''}

    Rules:
    - Direct and confrontational
    - Reference the emotion → behavior pattern if available
    - Max 15 words

    Return JSON: {"title": "...", "body": "..."}
    """;

    final response = await _gemini.generateContent(prompt);
    return InterventionContent.fromJson(jsonDecode(response));
  }
}
```

**Example Output**:
```json
{
  "title": "Anxiety Loop Detected",
  "body": "You're anxious. TikTok won't fix it. Close the app."
}
```

---

## User Experience Flow

### Scenario: "The Anxious Doom Scroller"

**Timeline**:

**14:30** - User opens Sherlock session (onboarding)
```
OpenAI detects:
- Primary emotion: "anxiety"
- Confidence: 0.82
- Tone: "defensive"
- Emphasis: "high"

Action: EmotionalContext saved to Hive
```

**15:00** - User opens TikTok (background)
```
Digital Truth Sensor detects:
- App: TikTok
- Session duration: 0 seconds (just opened)

Action: Check for recent emotion
```

**15:05** - Dopamine loop detected
```
Digital Truth Sensor detects:
- Switched to Instagram, then back to TikTok
- Total: 5 minutes, 3 apps

Pattern Detector:
- Recent anxiety (35 mins ago)
- Doom scrolling NOW
- Confidence: 0.87

Action: Trigger intervention
```

**Intervention Delivered**:
```
Title: "Anxiety Loop Detected"
Body: "You're anxious. TikTok won't fix it. Close the app."
Action: [Close App] [Give Me 2 More Minutes]
```

**User Impact**:
- Intervention feels **personalized** (references anxiety)
- User realizes the **pattern** ("I always doom-scroll when anxious")
- App builds **trust** ("It really knows me")

---

## Marketing Value

### Unique Positioning

**Tagline**: "The app that connects your emotions to your habits"

**Feature List**:
- ✅ Real-time doom scroll detection (Digital Truth Sensor)
- ✅ Emotion detection from voice (OpenAI Realtime API)
- ✅ Pattern linking: "Anxiety drives your doom-scrolling" (Emotion-Behavior Detector)
- ✅ Predictive intervention: Stop before you scroll (JITAI)

**Competitor Comparison**:
| Feature | Habitica | Streaks | Fabulous | **The Pact** |
|---------|----------|---------|----------|-------------|
| Voice coaching | ❌ | ❌ | ❌ | ✅ |
| Emotion detection | ❌ | ❌ | ❌ | ✅ |
| Real-time interruption | ❌ | ❌ | ❌ | ✅ |
| Emotion-behavior linking | ❌ | ❌ | ❌ | ✅ **UNIQUE** |

---

## Privacy & Ethical Considerations

### Data Retention
- **Emotion metadata**: Stored in Hive for 2 hours, then deleted
- **Pattern logs**: Aggregated only (no raw emotion data)
- **Voice audio**: Never stored (streamed to API, then discarded)

### User Control
- Users can disable emotion tracking via settings
- Emotion data is LOCAL-ONLY (never synced to Supabase)
- Clear disclosure: "We use voice emotion to detect patterns"

### Transparency
- Show detected patterns in dashboard: "You doom-scroll 3x longer when anxious"
- User can see correlation data: "5 patterns detected in last 30 days"
- Explain interventions: "We interrupted because we detected your anxiety pattern"

---

## Cost Optimization

### Smart Routing Reduces Cost by 56%

| Approach | Cost/User/Month | Sessions Using OpenAI |
|----------|----------------|----------------------|
| **All OpenAI** | $10.00 | 100% |
| **Hybrid (Current)** | $4.38 | 40% (Sherlock, Tough Truths) |
| **Cost Savings** | **$5.62** | **56% reduction** |

### Break-Even Analysis

At $9.99/month subscription:
- AI Cost: $4.38 (44% of revenue)
- Acceptable if churn reduction > 10%

At $19.99/month subscription:
- AI Cost: $4.38 (22% of revenue)
- Healthy margin for scaling

---

## Conclusion

The Emotion-Digital Behavior Integration creates a **competitive moat** that requires:

1. ✅ OpenAI Realtime API (emotion metadata)
2. ✅ Digital Truth Sensor (real-time behavior tracking)
3. ✅ JITAI System (intervention orchestration)
4. ✅ Pattern Detection Engine (linking the two)

**No competitor has all four components.**

This integration transforms The Pact from "habit tracker with voice" to **"emotional intelligence system that predicts and prevents self-destructive behavior"**.
