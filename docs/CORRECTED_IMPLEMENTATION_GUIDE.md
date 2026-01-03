# CORRECTED: Codebase-Aligned Implementation Guide

**Date**: January 3, 2026
**Purpose**: Implementation plan aligned with actual codebase patterns and existing infrastructure

---

## Critical Corrections from Audit

### ❌ INCORRECT Assumptions (from original plan)

1. **ContextSnapshotBuilder** → Actually **deprecated**, use `ContextService` + `context_snapshot_aggregator`
2. **New `EmotionalContext` entity** → Should **extend existing `DigitalContext`** class
3. **New `EmotionProvider`** → Should integrate into **existing `JITAIProvider`**
4. **Custom `DecisionTrigger` values** → Must add to **existing enum** in `jitai_decision_engine.dart`
5. **Separate emotion storage** → Should integrate with **existing `context_snapshot_aggregator`** pattern

### ✅ CORRECT Patterns (from codebase)

```dart
// Existing pattern for sensor integration
lib/data/services/jitai/context_snapshot_aggregator.dart
├── _captureDigital() ← Already captures DigitalTruthSensor data
├── _captureBiometric()
├── _captureCalendar()
└── Future.wait([...]) ← Parallel sensor reads

// Existing provider initialization (main.dart:212-218)
await Future.wait([
  settingsProvider.initialize(),
  userProvider.initialize(),
  habitProvider.initialize(),
  psychometricProvider.initialize(),
  jitaiProvider.initialize(weatherApiKey: JITAIConfig.openWeatherMapApiKey),
]);

// Existing provider wiring (main.dart:279-283)
ChangeNotifierProvider.value(value: settingsProvider),
ChangeNotifierProvider.value(value: userProvider),
ChangeNotifierProvider.value(value: habitProvider),
ChangeNotifierProvider.value(value: psychometricProvider),
ChangeNotifierProvider.value(value: jitaiProvider),
```

---

## Corrected Implementation Plan

### **Phase 1: Extend Existing DigitalContext** (NOT new entity)

**File**: `lib/domain/entities/context_snapshot.dart` (UPDATE existing DigitalContext)

```dart
/// Digital behavior context from App Usage APIs
class DigitalContext {
  // EXISTING FIELDS
  final int distractionMinutes; // Total dopamine app time today
  final String? apexDistractor; // Most used app (e.g., "TikTok")
  final double distractionZScore; // Relative to user's baseline
  final String? witnessName; // Name of accountability partner
  final DateTime capturedAt;

  // NEW FIELDS (Phase 65 - Guardian Mode)
  final int? currentSessionMinutes; // ← Active doom scroll duration
  final bool isActivelyDoomScrolling; // ← Currently in distraction app
  final int? sessionCount; // ← Number of distraction sessions today
  final DopamineLoopAlert? recentLoop; // ← Last detected loop

  // NEW FIELDS (Phase 65 - Emotion)
  final String? primaryEmotion; // ← From OpenAI voice session
  final double? emotionalIntensity; // ← 0.0-1.0
  final String? emotionalTone; // ← "defensive", "engaged"
  final DateTime? emotionCapturedAt; // ← When emotion was detected

  DigitalContext({
    required this.distractionMinutes,
    this.apexDistractor,
    this.distractionZScore = 0.0,
    this.witnessName,
    required this.capturedAt,
    // NEW
    this.currentSessionMinutes,
    this.isActivelyDoomScrolling = false,
    this.sessionCount,
    this.recentLoop,
    this.primaryEmotion,
    this.emotionalIntensity,
    this.emotionalTone,
    this.emotionCapturedAt,
  });

  /// Is emotion data stale? (older than 2 hours)
  bool get isEmotionStale {
    if (emotionCapturedAt == null) return true;
    return DateTime.now().difference(emotionCapturedAt!) > Duration(hours: 2);
  }

  /// Calculate vulnerability boost from emotion (for JITAI V-O calc)
  double get emotionVulnerabilityBoost {
    if (primaryEmotion == null || emotionalIntensity == null || isEmotionStale) {
      return 0.0;
    }

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

  /// Is user in a high-distraction state? (z-score > 1)
  bool get isHighDistraction => distractionZScore > 1.0;

  Map<String, dynamic> toJson() => {
        'distractionMinutes': distractionMinutes,
        'apexDistractor': apexDistractor,
        'distractionZScore': distractionZScore,
        'witnessName': witnessName,
        'capturedAt': capturedAt.toIso8601String(),
        // NEW
        'currentSessionMinutes': currentSessionMinutes,
        'isActivelyDoomScrolling': isActivelyDoomScrolling,
        'sessionCount': sessionCount,
        'recentLoop': recentLoop?.toJson(),
        'primaryEmotion': primaryEmotion,
        'emotionalIntensity': emotionalIntensity,
        'emotionalTone': emotionalTone,
        'emotionCapturedAt': emotionCapturedAt?.toIso8601String(),
      };

  factory DigitalContext.fromJson(Map<String, dynamic> json) {
    return DigitalContext(
      distractionMinutes: json['distractionMinutes'] as int,
      apexDistractor: json['apexDistractor'] as String?,
      distractionZScore: (json['distractionZScore'] as num?)?.toDouble() ?? 0.0,
      witnessName: json['witnessName'] as String?,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      // NEW
      currentSessionMinutes: json['currentSessionMinutes'] as int?,
      isActivelyDoomScrolling: json['isActivelyDoomScrolling'] as bool? ?? false,
      sessionCount: json['sessionCount'] as int?,
      recentLoop: json['recentLoop'] != null
          ? DopamineLoopAlert.fromJson(json['recentLoop'])
          : null,
      primaryEmotion: json['primaryEmotion'] as String?,
      emotionalIntensity: (json['emotionalIntensity'] as num?)?.toDouble(),
      emotionalTone: json['emotionalTone'] as String?,
      emotionCapturedAt: json['emotionCapturedAt'] != null
          ? DateTime.parse(json['emotionCapturedAt'] as String)
          : null,
    );
  }
}

/// Dopamine loop alert (from DigitalTruthSensor)
class DopamineLoopAlert {
  final List<String> apps; // Switched between these apps
  final int switchCount;
  final Duration windowDuration;
  final DateTime detectedAt;

  DopamineLoopAlert({
    required this.apps,
    required this.switchCount,
    required this.windowDuration,
    required this.detectedAt,
  });

  String get description {
    return 'Switched between ${apps.join(', ')} $switchCount times in ${windowDuration.inMinutes} min';
  }

  Map<String, dynamic> toJson() => {
        'apps': apps,
        'switchCount': switchCount,
        'windowDurationMs': windowDuration.inMilliseconds,
        'detectedAt': detectedAt.toIso8601String(),
      };

  factory DopamineLoopAlert.fromJson(Map<String, dynamic> json) {
    return DopamineLoopAlert(
      apps: (json['apps'] as List).cast<String>(),
      switchCount: json['switchCount'] as int,
      windowDuration: Duration(milliseconds: json['windowDurationMs'] as int),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );
  }
}
```

---

### **Phase 2: Update DecisionTrigger Enum** (NOT new file)

**File**: `lib/domain/services/jitai_decision_engine.dart` (UPDATE existing enum at line 1037)

```dart
enum DecisionTrigger {
  scheduled, // Regular check (existing)
  appOpen, // User opened app (existing)
  locationChange, // Geofence trigger (existing)
  calendarEvent, // Meeting ended (existing)
  manual, // User requested (existing)
  contextChange, // Context changed significantly (existing - from jitai_provider.dart:197)
  guardianMode, // ← NEW: Guardian Mode detected doom scrolling
  dopamineLoop, // ← NEW: Dopamine loop pattern detected
}
```

---

### **Phase 3: Extend context_snapshot_aggregator** (NOT new service)

**File**: `lib/data/services/jitai/context_snapshot_aggregator.dart` (UPDATE existing _captureDigital method)

```dart
/// Capture digital context (screen time + emotion)
Future<DigitalContext?> _captureDigital() async {
  try {
    if (!_digitalSensor.isSupported) {
      return null;
    }

    // EXISTING: Get daily aggregates
    final distractionMinutes = await _digitalSensor.getDopamineBurnMinutes();
    final apexDistractor = await _digitalSensor.getApexDistractor();

    // Calculate Z-score relative to baseline
    final distractionZ = _baselineTracker.distractionZScore(distractionMinutes);
    _baselineTracker.updateDistractionBaseline(distractionMinutes);

    // NEW: Get real-time session data
    final stats = await _digitalSensor.getDistractionStats();
    final sessions = stats['sessions'] as List<AppSession>?;

    // Find active session
    final activeSession = sessions?.lastWhere(
      (s) => s.isActive,
      orElse: () => null,
    );

    // NEW: Check for recent dopamine loop
    final loopAlert = await _digitalSensor.detectDopamineLoop();

    // NEW: Load emotion from Hive (stored by VoiceSessionManager)
    final emotion = await _loadEmotionFromHive();

    return DigitalContext(
      // EXISTING
      distractionMinutes: distractionMinutes,
      apexDistractor: _packageToAppName(apexDistractor),
      distractionZScore: distractionZ,
      capturedAt: DateTime.now(),
      // NEW
      currentSessionMinutes: activeSession?.duration.inMinutes,
      isActivelyDoomScrolling: activeSession != null,
      sessionCount: stats['sessionCount'] as int?,
      recentLoop: loopAlert != null
          ? DopamineLoopAlert(
              apps: loopAlert.sessions.map((s) => s.appName).toSet().toList(),
              switchCount: loopAlert.switchCount,
              windowDuration: loopAlert.windowDuration,
              detectedAt: loopAlert.detectedAt,
            )
          : null,
      primaryEmotion: emotion?.primaryEmotion,
      emotionalIntensity: emotion?.confidence,
      emotionalTone: emotion?.tone,
      emotionCapturedAt: emotion?.capturedAt,
    );
  } catch (e) {
    debugPrint('ContextSnapshotAggregator: Digital capture failed: $e');
    return null;
  }
}

/// Load latest emotion from Hive (stored by VoiceSessionManager)
Future<_EmotionData?> _loadEmotionFromHive() async {
  try {
    final box = await Hive.openBox<Map>('emotional_context');
    final json = box.get('latest_emotion');
    if (json == null) return null;

    final emotion = _EmotionData.fromJson(Map<String, dynamic>.from(json));

    // Check if stale (> 2 hours)
    if (DateTime.now().difference(emotion.capturedAt) > Duration(hours: 2)) {
      await box.delete('latest_emotion'); // Clean up stale data
      return null;
    }

    return emotion;
  } catch (e) {
    debugPrint('Failed to load emotion from Hive: $e');
    return null;
  }
}

class _EmotionData {
  final String? primaryEmotion;
  final double? confidence;
  final String? tone;
  final DateTime capturedAt;

  _EmotionData({
    this.primaryEmotion,
    this.confidence,
    this.tone,
    required this.capturedAt,
  });

  factory _EmotionData.fromJson(Map<String, dynamic> json) {
    return _EmotionData(
      primaryEmotion: json['primaryEmotion'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      tone: json['tone'] as String?,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
    );
  }
}
```

---

### **Phase 4: Update VoiceSessionManager** (NOT new service)

**File**: `lib/data/services/voice_session_manager.dart` (UPDATE existing startSession method)

```dart
Future<void> startSession({
  required VoiceSessionType type,
  // ... existing params
}) async {
  // ... existing code ...

  // NEW: Select provider based on session type
  final selector = VoiceProviderSelector();
  final recommendation = selector.selectForSession(sessionType: type);

  if (recommendation.provider == 'openai') {
    // Use OpenAI with emotion capture
    final openAIService = OpenAILiveService(
      // ... existing callbacks ...
      onEmotionDetected: (emotionMeta) async {
        await _storeEmotionInHive(emotionMeta);
      },
    );
    // ... start session ...
  } else {
    // Use Gemini (existing path)
    // ... existing code ...
  }
}

/// Store emotion in Hive for JITAI access
Future<void> _storeEmotionInHive(EmotionMetadata meta) async {
  if (meta.primaryEmotion == null) return;

  try {
    final box = await Hive.openBox<Map>('emotional_context');
    await box.put('latest_emotion', {
      'primaryEmotion': meta.primaryEmotion,
      'confidence': meta.confidence,
      'tone': meta.tone,
      'capturedAt': DateTime.now().toIso8601String(),
    });

    debugPrint('Emotion stored: ${meta.primaryEmotion} (${meta.confidence})');
  } catch (e) {
    debugPrint('Failed to store emotion: $e');
  }
}
```

---

### **Phase 5: Update V-O Calculator** (NOT new file)

**File**: `lib/domain/services/vulnerability_opportunity_calculator.dart` (UPDATE existing calculate method)

```dart
static VOState calculate({
  required ContextSnapshot context,
  required PsychometricProfile profile,
}) {
  double vulnerability = 0.5; // Base
  List<String> explanations = [];

  // ... existing biometric, calendar, weather calculations ...

  // NEW: Emotional vulnerability boost
  if (context.digital != null && !context.digital!.isEmotionStale) {
    final emotionBoost = context.digital!.emotionVulnerabilityBoost;
    vulnerability += emotionBoost;

    if (emotionBoost > 0) {
      explanations.add(
        'Recent ${context.digital!.primaryEmotion} detected'
      );
    }
  }

  // NEW: Active doom scrolling boost
  if (context.digital?.isActivelyDoomScrolling == true) {
    vulnerability += 0.15; // 15% boost
    explanations.add('Currently doom scrolling');
  }

  // NEW: Dopamine loop detected boost
  if (context.digital?.recentLoop != null) {
    vulnerability += 0.20; // 20% boost
    explanations.add(
      'Dopamine loop: ${context.digital!.recentLoop!.description}'
    );
  }

  return VOState(
    vulnerability: vulnerability.clamp(0.0, 1.0),
    opportunity: opportunity.clamp(0.0, 1.0),
    explanation: explanations.join(', '),
  );
}
```

---

### **Phase 6: Add Guardian Mode to JITAIProvider** (NOT new provider)

**File**: `lib/data/providers/jitai_provider.dart` (ADD new methods to existing class)

```dart
class JITAIProvider extends ChangeNotifier {
  // ... existing code ...

  // NEW: Guardian Mode state
  bool _guardianModeActive = false;
  DateTime? _lastGuardianCheck;

  bool get isGuardianModeActive => _guardianModeActive;

  /// Enable Guardian Mode (real-time doom scroll detection)
  Future<void> startGuardianMode() async {
    if (!_isInitialized) return;

    _guardianModeActive = true;
    notifyListeners();

    // Start periodic checks (every 5 seconds when guardian is active)
    _startGuardianModePolling();
  }

  /// Disable Guardian Mode
  Future<void> stopGuardianMode() async {
    _guardianModeActive = false;
    notifyListeners();
  }

  /// Guardian Mode polling loop (real-time detection)
  void _startGuardianModePolling() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      if (!_guardianModeActive) {
        timer.cancel();
        return;
      }

      await _checkGuardianMode();
    });
  }

  /// Check for doom scrolling via Guardian Mode
  Future<void> _checkGuardianMode() async {
    // Rate limit
    if (_lastGuardianCheck != null &&
        DateTime.now().difference(_lastGuardianCheck!) < Duration(seconds: 5)) {
      return;
    }
    _lastGuardianCheck = DateTime.now();

    // Build context (includes digital + emotion data)
    final context = await _contextBuilder.build(
      habit: _getCurrentHabit(), // Get active habit or null
    );

    // Check if actively doom scrolling
    if (context.digital?.isActivelyDoomScrolling == true) {
      final sessionMinutes = context.digital!.currentSessionMinutes!;

      // Determine intervention tier
      if (sessionMinutes >= 20) {
        await _triggerGuardianIntervention(context, tier: 3);
      } else if (sessionMinutes >= 10) {
        await _triggerGuardianIntervention(context, tier: 2);
      } else if (sessionMinutes >= 5) {
        await _triggerGuardianIntervention(context, tier: 1);
      }
    }

    // Check for dopamine loop
    if (context.digital?.recentLoop != null) {
      await _triggerGuardianIntervention(context, tier: 0); // Tier 0 = loop alert
    }
  }

  /// Trigger Guardian Mode intervention
  Future<void> _triggerGuardianIntervention(
    ContextSnapshot context, {
    required int tier,
  }) async {
    final profile = _getCurrentProfile();
    if (profile == null) return;

    // Decide intervention
    final decision = await _decisionEngine.decide(
      context: context,
      profile: profile,
      habit: _getCurrentHabit(),
      trigger: tier == 0 ? DecisionTrigger.dopamineLoop : DecisionTrigger.guardianMode,
    );

    if (decision.shouldIntervene) {
      // Deliver based on tier
      if (tier >= 2) {
        // Full overlay intervention
        await _notificationService.deliverOverlayIntervention(decision);
      } else {
        // Standard notification
        await _notificationService.deliverIntervention(decision);
      }

      // Set as active
      _activeIntervention = ActiveIntervention(
        decision: decision,
        triggeredAt: DateTime.now(),
        habitId: decision.habitId ?? '',
        habitName: decision.habitName ?? 'Digital Behavior',
      );
      notifyListeners();
    }
  }

  // Helper methods (to be implemented)
  Habit? _getCurrentHabit() => null; // Get from HabitProvider
  PsychometricProfile? _getCurrentProfile() => null; // Get from PsychometricProvider
}
```

---

### **Phase 7: Update main.dart Initialization** (NOT new wiring)

**File**: `lib/main.dart` (UPDATE existing initialization at line 217)

```dart
// Initialize providers (async operations)
await Future.wait([
  settingsProvider.initialize(),
  userProvider.initialize(),
  habitProvider.initialize(),
  psychometricProvider.initialize(),
  jitaiProvider.initialize(weatherApiKey: JITAIConfig.openWeatherMapApiKey),
]);

// NEW: Initialize Guardian Mode if user enabled it
final guardianModeEnabled = settingsProvider.guardianModeEnabled; // Add this setting
if (guardianModeEnabled) {
  await jitaiProvider.startGuardianMode();
}

if (kDebugMode) {
  debugPrint('Phase 34: Shadow Wiring initialized (Dark Launch)');
  debugPrint('  - SettingsProvider: ready');
  debugPrint('  - UserProvider: ready');
  debugPrint('  - HabitProvider: ready');
  debugPrint('  - PsychometricProvider: ready');
  debugPrint('  - JITAIProvider: ready');
  debugPrint('  - Guardian Mode: ${guardianModeEnabled ? "active" : "inactive"}'); // NEW
}
```

**NO NEW PROVIDERS NEEDED** - Guardian Mode is part of JITAIProvider.

---

## Summary of Corrections

| Original Plan | Corrected Approach | Reason |
|---------------|-------------------|--------|
| New `EmotionalContext` entity | Extend existing `DigitalContext` | Keep related data together, avoid duplication |
| New `EmotionProvider` | Add to `JITAIProvider` | JITAI already manages context/interventions |
| New `EmotionStorageService` | Use Hive directly in methods | Simple key-value, no need for service class |
| Use `ContextSnapshotBuilder` | Use `context_snapshot_aggregator` | Builder is deprecated, aggregator is current |
| New `GuardianModeProvider` | Add to `JITAIProvider` | Guardian Mode is intervention type, fits JITAI |
| Custom trigger enum | Add to existing `DecisionTrigger` | Maintain single source of truth |
| Separate pattern detector | Integrate into aggregator | Pattern = context data, belongs in aggregator |

---

## Files Modified (Corrected)

| File | Changes | LOC Impact |
|------|---------|------------|
| `lib/domain/entities/context_snapshot.dart` | Extend `DigitalContext` with emotion + session fields | +80 |
| `lib/domain/services/jitai_decision_engine.dart` | Add `guardianMode`, `dopamineLoop` to enum | +2 |
| `lib/data/services/jitai/context_snapshot_aggregator.dart` | Update `_captureDigital()` to include emotion + sessions | +60 |
| `lib/data/services/voice_session_manager.dart` | Add `_storeEmotionInHive()` callback | +25 |
| `lib/domain/services/vulnerability_opportunity_calculator.dart` | Use emotion boost in calc | +20 |
| `lib/data/providers/jitai_provider.dart` | Add Guardian Mode methods | +100 |
| `lib/main.dart` | Initialize Guardian Mode if enabled | +5 |

**Total**: ~292 LOC (vs original 2,500 LOC estimate)

**90% reduction in code** by leveraging existing infrastructure.

---

## Implementation Timeline (Corrected)

### **Day 1: Core Data Extensions**
- [ ] Update `DigitalContext` entity (+80 LOC)
- [ ] Add `DecisionTrigger` enum values (+2 LOC)
- [ ] Test: Compile and verify no breaking changes

### **Day 2: Context Aggregation**
- [ ] Update `context_snapshot_aggregator._captureDigital()` (+60 LOC)
- [ ] Add Hive emotion loading helper (+30 LOC)
- [ ] Test: Context includes emotion + session data

### **Day 3: Emotion Capture**
- [ ] Update `VoiceSessionManager` with emotion storage (+25 LOC)
- [ ] Test: Emotion stored after Sherlock/Tough Truths session

### **Day 4: V-O Calculator Integration**
- [ ] Update `VulnerabilityOpportunityCalculator` (+20 LOC)
- [ ] Test: Emotion boosts vulnerability score

### **Day 5: Guardian Mode Logic**
- [ ] Add Guardian Mode methods to `JITAIProvider` (+100 LOC)
- [ ] Test: Polling loop detects doom scrolling

### **Day 6: Main.dart Wiring + Settings**
- [ ] Update `main.dart` initialization (+5 LOC)
- [ ] Add Guardian Mode toggle to settings UI (+50 LOC)
- [ ] Test: User can enable/disable Guardian Mode

### **Day 7: Polish + Testing**
- [ ] Integration tests (emotion → JITAI → intervention)
- [ ] Performance testing (battery, memory)
- [ ] Build and QA

**Total: 7 days, 372 LOC**

---

## Next Steps

1. Review this corrected plan
2. Start with Day 1 (data extensions)
3. Commit after each day for incremental progress
4. Deploy Phase 1 (Guardian Mode) after Day 5

**This aligns perfectly with your existing codebase architecture.** ✅
