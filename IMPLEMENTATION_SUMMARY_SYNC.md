# Resume Sync Strategy — Implementation Summary

## The Problem: Widget Split-Brain

When the home screen widget marks a habit as complete, it runs in a **background isolate** that writes directly to Hive storage. Meanwhile, the Flutter app may be:

1. **Suspended in memory** — `AppState` holds stale in-memory data
2. **Completely killed** — Not an issue (fresh load from Hive on startup)
3. **Running in foreground** — Also not an issue (user is in-app anyway)

**The critical scenario is #1**: App is suspended, widget updates Hive, user opens app, and:
- UI shows "Incomplete" when the habit is actually done
- Daily notification fires for an already-completed habit
- User misses the reward/celebration flow

This is a classic **split-brain** problem in distributed systems.

---

## The Solution: Lifecycle-Aware Reconciliation

### Core Concept

When the app resumes from background, immediately:
1. Reload habit data from Hive (source of truth)
2. Compare with in-memory state
3. If Hive says "complete" but memory says "incomplete" → SYNC
4. Cancel notifications + trigger reward flow

### Architecture Decision

We chose to implement this at the **AppState level** rather than the widget level because:
- AppState is the single source of truth for in-memory state
- AppState already manages Hive persistence
- AppState owns the NotificationService
- Centralizing lifecycle logic prevents scattered observers

---

## Implementation Details

### 1. AppState Changes (`lib/data/app_state.dart`)

**Mixin Added:**
```dart
class AppState extends ChangeNotifier with WidgetsBindingObserver {
```

**New Fields:**
```dart
// Tracks if we detected an external completion (from widget)
bool _externalCompletionDetected = false;

// Concurrency guard: timestamp of last in-app state modification
DateTime? _lastStateModification;

// Lock to prevent concurrent reconciliation operations
bool _isReconciling = false;
```

**Lifecycle Registration:**
```dart
Future<void> initialize() async {
  // Register lifecycle observer for Resume Sync Strategy
  WidgetsBinding.instance.addObserver(this);
  // ... rest of initialization
}

@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  super.dispose();
}
```

**Lifecycle Handler:**
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    _reconcileWithHive();
  }
}
```

**The Core Reconciliation Method:**
```dart
Future<void> _reconcileWithHive() async {
  // Prevent concurrent reconciliation
  if (_isReconciling) return;
  _isReconciling = true;

  try {
    // Capture current in-memory state BEFORE loading from Hive
    final wasCompletedInMemory = isHabitCompletedToday();

    // Load fresh data from Hive
    final habitJson = _dataBox!.get('currentHabit');
    final hiveHabit = Habit.fromJson(Map<String, dynamic>.from(habitJson));

    // Check if Hive has a completion that in-memory doesn't know about
    final hiveCompletedToday = _isHabitCompletedTodayFromData(hiveHabit);

    if (hiveCompletedToday && !wasCompletedInMemory) {
      // SPLIT-BRAIN DETECTED!
      _currentHabit = hiveHabit;
      _externalCompletionDetected = true;

      // Cancel daily reminder so we don't nag the user
      await _notificationService.cancelDailyReminder();

      // Trigger reward flow for widget users
      _shouldShowRewardFlow = true;

      notifyListeners();
    }
  } finally {
    _isReconciling = false;
  }
}
```

---

### 2. NotificationService Changes (`lib/data/notification_service.dart`)

**New Method:**
```dart
/// Cancel the daily habit reminder notification
///
/// Critical for Resume Sync Strategy:
/// When the widget marks a habit as complete, the app needs to cancel
/// the daily reminder so we don't nag the user for something they already did.
Future<void> cancelDailyReminder() async {
  if (!_initialized) return;

  try {
    await _notifications.cancel(0); // Daily reminder
    await _notifications.cancel(1); // Snooze notification
  } catch (e) {
    // Handle gracefully
  }
}
```

---

### 3. TodayScreenController Changes (`lib/features/today/controllers/today_screen_controller.dart`)

**Updated `onScreenResumed()`:**
```dart
Future<void> onScreenResumed() async {
  // Trigger reconciliation as backup to AppState's lifecycle observer
  await appState.reconcileWithHiveIfNeeded();

  // Check what dialogs should be shown
  if (appState.shouldShowRewardFlow) {
    if (appState.externalCompletionDetected) {
      debugPrint('Showing reward for WIDGET completion');
      appState.clearExternalCompletionFlag();
    }
    showRewardDialog();
  } else if (appState.shouldShowRecoveryPrompt) {
    showRecoveryDialog();
  }
}
```

---

## Concurrency Guard

The implementation includes protection against race conditions:

### Scenario: Widget and App Update Simultaneously

```
Time 0ms: Widget starts updating Hive
Time 5ms: User opens app, triggers _reconcileWithHive()
Time 10ms: Widget finishes Hive write
Time 15ms: Reconciliation reads Hive
```

**Protection Mechanisms:**

1. **`_isReconciling` Lock** — Prevents multiple reconciliation calls from stepping on each other

2. **Atomic Hive Operations** — Hive writes are atomic per-key, so we always read a complete habit object

3. **Post-Read Comparison** — We compare AFTER reading from Hive, so we get the latest state regardless of timing

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    WIDGET COMPLETION FLOW                        │
└─────────────────────────────────────────────────────────────────┘

Widget Tap ──► Background Isolate ──► Hive.put('currentHabit')
                                              │
                                              ▼
                                    [Hive Storage Updated]
                                              │
                                              ▼
User Opens App ──► AppLifecycleState.resumed
                              │
                              ▼
                   didChangeAppLifecycleState()
                              │
                              ▼
                     _reconcileWithHive()
                              │
            ┌─────────────────┼─────────────────┐
            │                 │                 │
            ▼                 ▼                 ▼
    Read In-Memory      Read Hive         Compare
    (not complete)      (complete!)       (MISMATCH!)
                                              │
                              ┌───────────────┴───────────────┐
                              │                               │
                              ▼                               ▼
                    Sync In-Memory                  Cancel Notifications
                              │                               │
                              └───────────┬───────────────────┘
                                          │
                                          ▼
                                 Set shouldShowRewardFlow
                                          │
                                          ▼
                                  notifyListeners()
                                          │
                                          ▼
                            UI Rebuilds + Reward Dialog Shows
```

---

## Testing Scenarios

### Scenario 1: Widget Completes While App Suspended

1. Open app, go to Today screen
2. Press Home button (app suspended)
3. Tap widget to complete habit
4. Open app again
5. **Expected**: App shows "Completed", reward dialog appears, notification cancelled

### Scenario 2: Widget Completes While App Killed

1. Force-close the app
2. Tap widget to complete habit
3. Open app
4. **Expected**: App loads fresh from Hive, shows "Completed" (no reconciliation needed)

### Scenario 3: Concurrent Widget/App Actions

1. Open app, keep Today screen visible
2. Quickly tap widget AND in-app complete button
3. **Expected**: No crash, habit shows as completed, only one reward shown

### Scenario 4: No Widget Completion

1. App suspended, no widget interaction
2. Resume app
3. **Expected**: No state changes, no reward dialog, normal flow

---

## Debug Logging

In debug mode, the system logs reconciliation events:

```
📱 App resumed - checking for external changes...
🔄 External completion detected! Syncing state...
   Hive says: Completed
   Memory said: Not completed
🔕 Daily reminder cancelled
🎉 Reward flow triggered for widget completion
```

---

## Files Changed

| File | Lines Added | Description |
|------|-------------|-------------|
| `lib/data/app_state.dart` | +170 | Lifecycle observer, reconciliation logic |
| `lib/data/notification_service.dart` | +20 | `cancelDailyReminder()` method |
| `lib/features/today/controllers/today_screen_controller.dart` | +20 | Async `onScreenResumed()` |
| `lib/features/today/today_screen.dart` | +2 | Comment update |

**Total: ~212 lines added**

---

## Future Considerations

### Multi-Habit Support

When we add multiple habits, the reconciliation logic needs to:
- Track which habit IDs were modified
- Only show reward for habits that were externally completed
- Handle concurrent widget updates for different habits

### Widget Implementation

The widget side needs to:
- Use `Hive.init()` in the background isolate
- Open the same 'habit_data' box
- Update habit using identical JSON structure
- Consider adding a `lastModifiedBy: 'widget'` field for debugging

### iOS Background Fetch

iOS handles background updates differently:
- May need to use `home_widget`'s iOS-specific callback mechanism
- Consider `WidgetKit` timeline updates

---

## Summary

The Resume Sync Strategy solves the split-brain problem between widget and app by:

1. **Detecting** external changes via Hive comparison on app resume
2. **Syncing** in-memory state to match Hive (source of truth)
3. **Cancelling** stale notifications that are no longer relevant
4. **Triggering** reward flow so widget users get their dopamine hit

This ensures a seamless user experience regardless of whether habits are completed in-app or via widget.

---

*Implementation completed: December 2024*
*Part of Atomic Habits Hook App v1.2.2*
