# Android Usage Stats API Research

**Date:** January 3, 2026
**Source:** Researcher Agent Analysis
**Applies to:** `lib/data/sensors/digital_truth_sensor.dart`

---

## Executive Summary

Research into Android's app usage tracking APIs revealed two key findings:
1. Google's restricted internal API (not usable)
2. A superior public API alternative (recommended implementation)

---

## Finding 1: Google Digital Wellbeing Internal API

### Discovery

Google's Digital Wellbeing app uses `UsageStatsManagerInternal` for real-time app usage tracking. This API provides instant notifications of app transitions without polling.

### Status: ❌ Not Actionable

| Attribute | Value |
|-----------|-------|
| API | `com.android.server.usage.UsageStatsManagerInternal` |
| Access Level | `@SystemApi` / `@hide` |
| Requires | System signature or privileged app status |
| Available to third-party | **No** |

### Implication

This explains why third-party apps cannot achieve the same real-time tracking quality as Google's first-party Digital Wellbeing. However, this is a dead end for The Pact app.

---

## Finding 2: UsageEvents.queryEvents() Alternative

### Discovery

Instead of using `queryUsageStats()` which returns aggregated bucket data, `queryEvents()` provides individual app transition events with precise timestamps.

### Status: ✅ Highly Actionable

### API Comparison

| Metric | `queryUsageStats()` (Current) | `queryEvents()` (Recommended) |
|--------|------------------------------|-------------------------------|
| **Return Type** | `List<UsageStats>` | `UsageEvents` iterator |
| **Granularity** | Time buckets (hourly/daily) | Individual events |
| **Timestamp Precision** | Bucket boundaries | Exact milliseconds |
| **Real-time Data** | Cached/delayed | Near real-time |
| **Event Types** | Totals only | FOREGROUND, BACKGROUND, etc. |

### Documentation Reference

- [UsageStatsManager.queryEvents()](https://developer.android.com/reference/android/app/usage/UsageStatsManager#queryEvents(long,%20long))
- [UsageEvents.Event](https://developer.android.com/reference/android/app/usage/UsageEvents.Event)

### Event Types Available

| Event Type | Value | Description |
|------------|-------|-------------|
| `MOVE_TO_FOREGROUND` | 1 | App moved to foreground |
| `MOVE_TO_BACKGROUND` | 2 | App moved to background |
| `ACTIVITY_RESUMED` | 15 | Activity resumed (API 29+) |
| `ACTIVITY_PAUSED` | 23 | Activity paused (API 29+) |

### Implementation Benefits for The Pact

1. **Dopamine Loop Detection**: Can detect rapid app switching (Instagram → TikTok → Twitter pattern)
2. **Binge Duration Calculation**: Calculate exact session lengths per distraction app
3. **Time-of-Day Analysis**: Precise timestamps enable hourly usage patterns
4. **Real-time Alerts**: Near real-time data enables "Distraction Alert" nudges

---

## Recommended Implementation

### Current Implementation (Using app_usage plugin)

```dart
// digital_truth_sensor.dart:43
List<AppUsageInfo> infos = await AppUsage().getAppUsage(midnight, now);
```

The `app_usage` Flutter plugin (v4.0.1) wraps `queryUsageStats()` which provides aggregated data.

### Proposed Enhancement

Create a platform channel to access `queryEvents()` directly:

```kotlin
// Android native (Kotlin)
fun getUsageEvents(startTime: Long, endTime: Long): List<AppEvent> {
    val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
    val events = usageStatsManager.queryEvents(startTime, endTime)
    val result = mutableListOf<AppEvent>()

    val event = UsageEvents.Event()
    while (events.hasNextEvent()) {
        events.getNextEvent(event)
        if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND ||
            event.eventType == UsageEvents.Event.MOVE_TO_BACKGROUND) {
            result.add(AppEvent(
                packageName = event.packageName,
                eventType = event.eventType,
                timestamp = event.timeStamp
            ))
        }
    }
    return result
}
```

```dart
// Flutter side
static const platform = MethodChannel('com.thepact/usage_events');

Future<List<AppTransition>> getAppTransitions() async {
  final events = await platform.invokeMethod('getUsageEvents', {
    'startTime': midnight.millisecondsSinceEpoch,
    'endTime': DateTime.now().millisecondsSinceEpoch,
  });
  return events.map((e) => AppTransition.fromMap(e)).toList();
}
```

---

## Priority Assessment

| Factor | Rating |
|--------|--------|
| User Impact | High - Enables dopamine loop detection |
| Implementation Effort | Medium - Requires platform channel |
| Risk | Low - Well-documented public API |
| Dependency | None - Uses native Android SDK |

### Recommendation

Add to **Layer 3 (Real-Time Intervention)** backlog as enhancement to `DigitalTruthSensor`. The current implementation is functional for MVP; this enhancement enables advanced features like:
- "You've switched between 3 distraction apps in 5 minutes"
- "Instagram session started 45 minutes ago"
- Real-time dopamine binge alerts

---

## Appendix: Researcher Agent Evaluation

| Criteria | Score | Notes |
|----------|-------|-------|
| Relevance | 5/5 | Directly applicable to existing code |
| Accuracy | 5/5 | Both findings verified against Android docs |
| Actionability | 4/5 | One finding unusable, one highly actionable |
| Documentation | 3/5 | Missing source URLs in original finding |
| Completeness | 4/5 | Good coverage, could include code samples |

**Overall**: The Researcher Agent provided valuable technical discovery that identifies a concrete improvement opportunity. The research correctly distinguished between theoretical knowledge (internal API) and practical implementation (queryEvents alternative).

---

## Implementation Status

**Date Implemented:** January 3, 2026

### Completed Work

| Component | File | Status |
|-----------|------|--------|
| Platform Channel (Kotlin) | `android/app/src/main/kotlin/co/thepact/app/MainActivity.kt` | ✅ Implemented |
| Event-based Tracking (Dart) | `lib/data/sensors/digital_truth_sensor.dart` | ✅ Implemented |
| Dopamine Loop Detection | `DigitalTruthSensor.detectDopamineLoop()` | ✅ Implemented |
| Session Statistics | `DigitalTruthSensor.getDistractionStats()` | ✅ Implemented |

### New Capabilities

1. **`getAppSessions()`** - Returns list of `AppSession` objects with precise timing
2. **`getDistractionSessions()`** - Filtered to distraction apps only
3. **`detectDopamineLoop()`** - Returns `DopamineLoopAlert` when rapid switching detected
4. **`getDistractionStats()`** - Session count, avg duration, longest session

### Backward Compatibility

- Legacy `getDailyUsage()`, `getDopamineBurnMinutes()`, `getApexDistractor()` preserved
- `getDopamineBurnMinutes()` now tries event-based first, falls back to legacy
