# Sprint Plan: Digital Truth Sensor + Emotion Integration

**Sprint Duration**: 1 week (all 3 phases compressed)
**Target**: Ship Guardian Mode + OpenAI Emotion + Pattern Linking

---

## Current State Assessment

### ✅ Already Implemented

| Component | File | Status |
|-----------|------|--------|
| **Digital Truth Sensor** | `lib/data/sensors/digital_truth_sensor.dart` | ✅ Event-based tracking ready |
| **UsageEvents API** | `android/app/src/main/kotlin/MainActivity.kt` | ✅ Native bridge implemented |
| **OpenAI Realtime Service** | `lib/data/sensors/openai_live_service.dart` | ✅ Emotion metadata extraction ready |
| **Voice Provider Selector** | `lib/domain/services/voice_provider_selector.dart` | ✅ Session-based routing ready |
| **JITAI Provider** | `lib/data/providers/jitai_provider.dart` | ✅ Infrastructure ready |
| **Context Builder** | `lib/data/services/context/context_snapshot_builder.dart` | ✅ Multi-sensor aggregation ready |

### ❌ Needs Implementation

| Component | Estimated Time | Priority |
|-----------|---------------|----------|
| **GuardianModeProvider** | 4 hours | P0 - Critical |
| **Guardian Foreground Service** (Android) | 6 hours | P0 - Critical |
| **EmotionalContext Entity** | 2 hours | P1 - High |
| **Emotion Storage Service** | 3 hours | P1 - High |
| **Pattern Detector** | 4 hours | P1 - High |
| **ContextSnapshot Integration** | 2 hours | P1 - High |
| **V-O Calculator Update** | 2 hours | P2 - Medium |
| **Intervention UI** | 6 hours | P0 - Critical |
| **Settings UI** | 4 hours | P2 - Medium |

**Total Estimated Time**: 33 hours (fits in 1 week with focused execution)

---

## Architecture Integration

### Provider Hierarchy (Extended)

```
main.dart
├── SettingsProvider
├── UserProvider
├── HabitProvider
├── PsychometricProvider
├── JITAIProvider (Existing)
│   └── Consumes: ContextSnapshotBuilder, DecisionEngine
├── GuardianModeProvider (NEW - Phase 1)
│   └── Consumes: DigitalTruthSensor, JITAIProvider
└── EmotionProvider (NEW - Phase 2)
    └── Consumes: EmotionStorageService, OpenAILiveService
```

### Data Flow (All 3 Phases Combined)

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER BEHAVIOR LAYER                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Voice Session                    Digital Behavior              │
│  ┌───────────────┐                ┌─────────────────┐           │
│  │ OpenAI Live   │                │ UsageEvents API │           │
│  │ (via VoiceSM) │                │ (via Guardian)  │           │
│  └───────┬───────┘                └────────┬────────┘           │
│          │                                  │                    │
│          ▼                                  ▼                    │
│  ┌───────────────────┐          ┌─────────────────────┐         │
│  │ EmotionProvider   │          │ GuardianModeProvider│         │
│  │ - Store emotion   │          │ - Monitor usage     │         │
│  │ - 2hr expiry      │          │ - Trigger alerts    │         │
│  └───────┬───────────┘          └─────────┬───────────┘         │
│          │                                  │                    │
│          └──────────────┬───────────────────┘                   │
│                         ▼                                        │
│            ┌────────────────────────────┐                       │
│            │  PatternDetectorService    │ (NEW - Phase 3)       │
│            │  - Link emotion+behavior   │                       │
│            │  - Detect causality        │                       │
│            └────────────┬───────────────┘                       │
│                         ▼                                        │
│            ┌────────────────────────────┐                       │
│            │  ContextSnapshotBuilder    │ (UPDATED)             │
│            │  + EmotionalContext field  │                       │
│            │  + Pattern field           │                       │
│            └────────────┬───────────────┘                       │
│                         ▼                                        │
│            ┌────────────────────────────┐                       │
│            │    JITAIDecisionEngine     │ (UPDATED)             │
│            │  - Use emotion in V-O calc │                       │
│            │  - Pattern-aware content   │                       │
│            └────────────┬───────────────┘                       │
│                         ▼                                        │
│            ┌────────────────────────────┐                       │
│            │  Intervention Delivery     │                       │
│            │  - Notification            │                       │
│            │  - System overlay          │                       │
│            └────────────────────────────┘                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Roadmap (7 Days)

### **Day 1-2: Phase 1 - Guardian Mode (Real-Time Interruption)**

#### Android Native Layer

**File**: `android/app/src/main/kotlin/co/thepact/app/GuardianModeService.kt` (NEW)

```kotlin
// Foreground service with adaptive polling
class GuardianModeService : Service() {
    private var pollInterval = 30_000L // 30s baseline
    private var sessionStart: Long = 0
    private val handler = Handler(Looper.getMainLooper())

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICATION_ID, createServiceNotification())
        startMonitoring()
        return START_STICKY
    }

    private fun startMonitoring() {
        handler.postDelayed(object : Runnable {
            override fun run() {
                checkCurrentApp()
                handler.postDelayed(this, pollInterval)
            }
        }, pollInterval)
    }

    private fun checkCurrentApp() {
        val currentApp = getCurrentForegroundApp()

        if (isDistractionApp(currentApp)) {
            pollInterval = 5_000L // Increase frequency

            val sessionDuration = System.currentTimeMillis() - sessionStart
            if (sessionDuration >= THRESHOLD_MS) {
                triggerFlutterIntervention(currentApp, sessionDuration)
            }
        } else {
            pollInterval = 30_000L // Decrease frequency
            sessionStart = 0
        }
    }

    private fun triggerFlutterIntervention(pkg: String, duration: Long) {
        // Send to Flutter via MethodChannel
        MethodChannel(flutterEngine.dartExecutor, CHANNEL)
            .invokeMethod("onDoomScrollDetected", mapOf(
                "packageName" to pkg,
                "durationMs" to duration
            ))
    }
}
```

**Integration Point**: `AndroidManifest.xml`
```xml
<service
    android:name=".GuardianModeService"
    android:foregroundServiceType="specialUse"
    android:exported="false">
    <property
        android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
        android:value="Real-time addiction intervention" />
</service>
```

#### Flutter Provider Layer

**File**: `lib/data/providers/guardian_mode_provider.dart` (NEW)

```dart
/// GuardianModeProvider - Real-Time Doom Scroll Detection
///
/// Manages the Guardian Mode foreground service and intervention delivery.
/// Integrates with JITAIProvider for intervention orchestration.
class GuardianModeProvider extends ChangeNotifier {
  static const _channel = MethodChannel('co.thepact/guardian_mode');

  final DigitalTruthSensor _sensor = DigitalTruthSensor();
  final JITAIProvider _jitaiProvider;

  bool _isActive = false;
  DoomScrollSession? _currentSession;
  List<GuardianAlert> _alertHistory = [];

  GuardianModeProvider(this._jitaiProvider);

  bool get isActive => _isActive;
  DoomScrollSession? get currentSession => _currentSession;
  List<GuardianAlert> get alertHistory => List.unmodifiable(_alertHistory);

  /// Start Guardian Mode monitoring
  Future<void> start() async {
    if (_isActive) return;

    // Check permissions
    final hasPermission = await _checkUsagePermission();
    if (!hasPermission) {
      throw GuardianModeException('Usage stats permission not granted');
    }

    // Start foreground service
    await _channel.invokeMethod('startGuardianService');

    // Listen for doom scroll events
    _channel.setMethodCallHandler(_handleNativeEvent);

    _isActive = true;
    notifyListeners();
  }

  /// Handle events from native service
  Future<void> _handleNativeEvent(MethodCall call) async {
    switch (call.method) {
      case 'onDoomScrollDetected':
        await _handleDoomScrollDetected(
          call.arguments['packageName'],
          call.arguments['durationMs'],
        );
        break;
    }
  }

  /// Handle doom scroll detection
  Future<void> _handleDoomScrollDetected(String pkg, int durationMs) async {
    final duration = Duration(milliseconds: durationMs);

    // Create session if new
    if (_currentSession == null || _currentSession!.packageName != pkg) {
      _currentSession = DoomScrollSession(
        packageName: pkg,
        startTime: DateTime.now().subtract(duration),
        detectedAt: DateTime.now(),
      );
    }

    // Determine intervention tier
    final tier = _getInterventionTier(duration);

    // Trigger JITAI intervention
    final alert = GuardianAlert(
      packageName: pkg,
      duration: duration,
      tier: tier,
      triggeredAt: DateTime.now(),
    );

    _alertHistory.add(alert);

    // Deliver intervention via JITAI
    await _deliverIntervention(alert);

    notifyListeners();
  }

  InterventionTier _getInterventionTier(Duration duration) {
    if (duration >= Duration(minutes: 20)) return InterventionTier.forcedClose;
    if (duration >= Duration(minutes: 10)) return InterventionTier.fullOverlay;
    if (duration >= Duration(minutes: 5)) return InterventionTier.notification;
    return InterventionTier.none;
  }

  /// Deliver intervention via JITAI system
  Future<void> _deliverIntervention(GuardianAlert alert) async {
    // Trigger JITAI decision with guardian trigger
    // (JITAI will handle intervention selection and delivery)
    await _jitaiProvider.triggerGuardianIntervention(
      packageName: alert.packageName,
      duration: alert.duration,
      tier: alert.tier,
    );
  }

  /// Stop Guardian Mode
  Future<void> stop() async {
    if (!_isActive) return;

    await _channel.invokeMethod('stopGuardianService');
    _isActive = false;
    _currentSession = null;
    notifyListeners();
  }

  Future<bool> _checkUsagePermission() async {
    // Implementation using app_usage plugin
    return true; // Stub
  }
}

class DoomScrollSession {
  final String packageName;
  final DateTime startTime;
  final DateTime detectedAt;

  DoomScrollSession({
    required this.packageName,
    required this.startTime,
    required this.detectedAt,
  });

  Duration get duration => detectedAt.difference(startTime);
}

class GuardianAlert {
  final String packageName;
  final Duration duration;
  final InterventionTier tier;
  final DateTime triggeredAt;

  GuardianAlert({
    required this.packageName,
    required this.duration,
    required this.tier,
    required this.triggeredAt,
  });
}

enum InterventionTier { none, notification, fullOverlay, forcedClose }
```

**Integration Point**: `lib/main.dart`
```dart
// Initialize Guardian Mode Provider
final guardianModeProvider = GuardianModeProvider(jitaiProvider);
```

---

### **Day 3-4: Phase 2 - OpenAI Emotion Routing**

#### Emotion Entity

**File**: `lib/domain/entities/emotional_context.dart` (NEW)

```dart
/// EmotionalContext: Captured emotion state from voice interactions
///
/// Data source: OpenAI Realtime API emotion metadata
/// Lifespan: Stored in Hive for 2 hours (stale after)
class EmotionalContext {
  final String? primaryEmotion; // e.g., "anxiety", "stress"
  final double? emotionalIntensity; // 0.0-1.0
  final String? tone; // e.g., "defensive", "engaged"
  final String? emphasis; // e.g., "high", "low"
  final DateTime capturedAt;

  EmotionalContext({
    this.primaryEmotion,
    this.emotionalIntensity,
    this.tone,
    this.emphasis,
    required this.capturedAt,
  });

  /// Calculate vulnerability boost for JITAI V-O calculation
  double get vulnerabilityBoost {
    if (primaryEmotion == null || emotionalIntensity == null) return 0.0;

    switch (primaryEmotion) {
      case 'anxiety':
      case 'stress':
        return emotionalIntensity! * 0.3; // Max 30% boost
      case 'sadness':
      case 'shame':
        return emotionalIntensity! * 0.25;
      case 'anger':
      case 'frustration':
        return emotionalIntensity! * 0.2;
      default:
        return 0.0;
    }
  }

  /// Check if emotion data is stale (older than 2 hours)
  bool get isStale {
    return DateTime.now().difference(capturedAt) > Duration(hours: 2);
  }

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

#### Emotion Storage

**File**: `lib/data/services/emotion_storage_service.dart` (NEW)

```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/emotional_context.dart';

/// EmotionStorageService - Persists emotional context with 2-hour expiry
class EmotionStorageService {
  static const String _boxName = 'emotional_context';
  static const String _latestKey = 'latest_emotion';

  Box<Map>? _box;

  /// Initialize Hive box
  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  /// Save latest emotional context
  Future<void> saveLatest(EmotionalContext emotion) async {
    if (_box == null) await init();
    await _box!.put(_latestKey, emotion.toJson());
  }

  /// Get latest emotional context (null if stale or missing)
  Future<EmotionalContext?> getLatest() async {
    if (_box == null) await init();

    final json = _box!.get(_latestKey);
    if (json == null) return null;

    try {
      final emotion = EmotionalContext.fromJson(Map<String, dynamic>.from(json));
      return emotion.isStale ? null : emotion;
    } catch (e) {
      debugPrint('EmotionStorageService: Failed to parse emotion: $e');
      return null;
    }
  }

  /// Clear expired emotion data
  Future<void> clearStale() async {
    if (_box == null) await init();

    final emotion = await getLatest();
    if (emotion == null || emotion.isStale) {
      await _box!.delete(_latestKey);
    }
  }
}
```

#### Voice Session Manager Integration

**File**: `lib/data/services/voice_session_manager.dart` (UPDATE)

```dart
class VoiceSessionManager {
  final EmotionStorageService _emotionStorage = EmotionStorageService();

  Future<void> startSession({
    required VoiceSessionType type,
    // ... existing params
  }) async {
    // Initialize emotion storage
    await _emotionStorage.init();

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

    // Store for JITAI access
    _emotionStorage.saveLatest(emotionContext);

    debugPrint('Emotion captured: ${emotionContext.primaryEmotion} (${emotionContext.emotionalIntensity})');
  }
}
```

---

### **Day 5-6: Phase 3 - Emotion-Digital Pattern Linking**

#### Pattern Detector

**File**: `lib/domain/services/emotion_behavior_pattern_detector.dart` (NEW)

```dart
/// Detects causal patterns linking emotional states to digital behaviors
class EmotionBehaviorPatternDetector {
  final EmotionStorageService _emotionStorage = EmotionStorageService();
  final DigitalTruthSensor _digitalSensor = DigitalTruthSensor();

  static const Duration _correlationWindow = Duration(hours: 2);

  /// Detect if recent emotional state correlates with current behavior
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
    return '$emotionTrigger → $behaviorResponse (${timeLag.inMinutes} min later)';
  }
}
```

#### ContextSnapshot Integration

**File**: `lib/domain/entities/context_snapshot.dart` (UPDATE)

```dart
class ContextSnapshot {
  // ... existing fields ...

  /// NEW: Emotional context from recent voice session
  final EmotionalContext? emotion;

  /// NEW: Detected emotion-behavior pattern
  final EmotionBehaviorPattern? detectedPattern;

  ContextSnapshot({
    // ... existing params ...
    this.emotion,
    this.detectedPattern,
  });

  factory ContextSnapshot.now({
    // ... existing params ...
    EmotionalContext? emotion,
    EmotionBehaviorPattern? detectedPattern,
  }) {
    return ContextSnapshot(
      // ... existing fields ...
      emotion: emotion?.isStale == true ? null : emotion,
      detectedPattern: detectedPattern,
    );
  }

  int get sensorCount {
    int count = 1; // Time
    // ... existing counts ...
    if (emotion != null && !emotion!.isStale) count++;
    return count;
  }
}
```

#### V-O Calculator Update

**File**: `lib/domain/services/vulnerability_opportunity_calculator.dart` (UPDATE)

```dart
class VulnerabilityOpportunityCalculator {
  static VOState calculate({
    required ContextSnapshot context,
    required PsychometricProfile profile,
  }) {
    double vulnerability = 0.5; // Base
    List<String> explanations = [];

    // ... existing biometric, calendar, weather calculations ...

    // NEW: Emotional vulnerability boost
    if (context.emotion != null && !context.emotion!.isStale) {
      vulnerability += context.emotion!.vulnerabilityBoost;
      explanations.add(
        'Recent ${context.emotion!.primaryEmotion} detected'
      );
    }

    // NEW: Pattern-based vulnerability boost
    if (context.detectedPattern != null) {
      vulnerability += 0.2; // 20% boost if pattern detected
      explanations.add(
        'Pattern detected: ${context.detectedPattern!.description}'
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

---

### **Day 7: Integration, Testing & Polish**

#### JITAI Provider Extension

**File**: `lib/data/providers/jitai_provider.dart` (UPDATE)

```dart
class JITAIProvider extends ChangeNotifier {
  // ... existing code ...

  final EmotionBehaviorPatternDetector _patternDetector =
      EmotionBehaviorPatternDetector();

  /// NEW: Trigger intervention from Guardian Mode
  Future<void> triggerGuardianIntervention({
    required String packageName,
    required Duration duration,
    required InterventionTier tier,
  }) async {
    if (!_isInitialized || !_isEnabled) return;

    // Build context with emotion and pattern detection
    final context = await _buildEnrichedContext();

    // Trigger intervention with guardian-specific logic
    // (will use pattern data if available)
    final decision = await _decisionEngine.decide(
      context: context,
      profile: _getCurrentProfile(),
      habit: null, // Not habit-specific
      trigger: DecisionTrigger.guardianMode,
    );

    if (decision.shouldIntervene) {
      await _notificationService.deliverIntervention(decision);
    }
  }

  /// Build context snapshot with emotion and pattern data
  Future<ContextSnapshot> _buildEnrichedContext() async {
    final baseContext = await _contextBuilder.build();

    // Add emotion if available
    final emotion = await _emotionStorage.getLatest();

    // Detect pattern if emotion exists
    final pattern = await _patternDetector.detectPattern();

    return ContextSnapshot.now(
      // ... base context fields ...
      emotion: emotion,
      detectedPattern: pattern,
    );
  }
}
```

#### Main.dart Wiring

**File**: `lib/main.dart` (UPDATE)

```dart
void main() async {
  // ... existing initialization ...

  // JITAI Provider (existing)
  final jitaiProvider = JITAIProvider();

  // NEW: Guardian Mode Provider
  final guardianModeProvider = GuardianModeProvider(jitaiProvider);

  // NEW: Emotion Storage Service
  final emotionStorage = EmotionStorageService();
  await emotionStorage.init();

  // ... rest of initialization ...

  runApp(
    MultiProvider(
      providers: [
        // ... existing providers ...
        ChangeNotifierProvider.value(value: jitaiProvider),
        ChangeNotifierProvider.value(value: guardianModeProvider), // NEW
      ],
      child: MyApp(/* ... */),
    ),
  );
}
```

---

## Testing Strategy

### Unit Tests

**File**: `test/unit/guardian_mode_provider_test.dart`
```dart
void main() {
  group('GuardianModeProvider', () {
    test('detects doom scrolling at 10-minute threshold', () async {
      // ...
    });

    test('escalates intervention tier based on duration', () async {
      // ...
    });
  });
}
```

### Integration Tests

**File**: `test/integration/emotion_pattern_integration_test.dart`
```dart
void main() {
  group('Emotion-Digital Pattern Integration', () {
    test('links anxiety to doom scrolling within 2 hours', () async {
      // 1. Capture anxiety emotion
      // 2. Trigger doom scroll detection 30 mins later
      // 3. Verify pattern detected
      // 4. Verify intervention references pattern
    });
  });
}
```

---

## Rollout Plan

### Day 1-2: Guardian Mode MVP
- ✅ Foreground service operational
- ✅ Basic notification intervention
- ✅ Permission flow UI
- 🎯 Target: Real-time interruption works

### Day 3-4: Emotion Capture
- ✅ OpenAI sessions capture emotion
- ✅ Emotion stored in Hive with 2hr expiry
- ✅ ContextSnapshot includes emotion
- 🎯 Target: V-O calculator uses emotion

### Day 5-6: Pattern Linking
- ✅ Pattern detector operational
- ✅ Interventions reference patterns
- ✅ Dashboard shows patterns
- 🎯 Target: "Anxiety drives your doom-scrolling" message delivered

### Day 7: Integration & Polish
- ✅ All three systems working together
- ✅ Settings UI for Guardian Mode
- ✅ Dashboard insights showing patterns
- 🎯 Target: Ship-ready build

---

## Success Criteria

### Phase 1 (Guardian Mode)
- [ ] User opens TikTok → Intervention within 10 seconds
- [ ] 5-minute tier: Notification delivered
- [ ] 10-minute tier: Full overlay delivered
- [ ] 20-minute tier: App force-closed (if user enabled)
- [ ] Battery drain < 3% daily

### Phase 2 (Emotion)
- [ ] Sherlock session detects anxiety → Stored in Hive
- [ ] Tough Truths session detects defensiveness → Stored in Hive
- [ ] Emotion data expires after 2 hours
- [ ] ContextSnapshot includes emotion if available

### Phase 3 (Pattern Linking)
- [ ] Anxiety + doom scrolling within 2hrs = Pattern detected
- [ ] Pattern referenced in intervention content
- [ ] Dashboard shows "Your Patterns" card
- [ ] 3+ patterns detected → Insights unlocked

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| **Play Store rejection** | Use `specialUse` foreground service, clear permission explanations |
| **Battery drain** | Adaptive polling (5s when active, 30s when idle) |
| **Permission denial** | Graceful degradation: Show "Guardian Mode requires permission" card |
| **Emotion data privacy** | 2-hour local storage only, never synced to cloud |
| **Pattern false positives** | Require 0.7+ confidence threshold |

---

## Post-Sprint: Marketing Launch

**Week 2 Tasks**:
1. Create demo video: "Watch The Pact interrupt doom-scrolling in real-time"
2. ASO update: "Real-time intervention + emotion detection"
3. Reddit post: /r/productivity, /r/nosurf
4. Product Hunt launch: "The app that stops you mid-scroll"
5. Blog post: "How we detect when you're lying to yourself"

---

## Summary

This sprint compresses 3 phases into 1 week by:
1. Leveraging existing infrastructure (JITAI, DigitalTruthSensor, OpenAI service)
2. Focusing on integration points, not reinvention
3. Shipping MVP of each phase, iterating post-sprint

**Outcome**: A working end-to-end system that:
- Detects doom scrolling in real-time (Guardian Mode)
- Captures emotion from voice sessions (OpenAI)
- Links emotion to behavior (Pattern Detector)
- Delivers personalized interventions (JITAI)

**Competitive Moat**: No competitor can replicate without all 4 components.
