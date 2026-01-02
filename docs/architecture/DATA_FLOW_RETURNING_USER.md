# Data Flow: Returning User Landing Page

## Overview

This document maps the complete data flow from storage to UI for a returning user's landing page experience. It identifies cache invalidation points, async boundaries, and potential strangler fig seams for future refactoring.

---

## 1. What Data Does a Returning User Need?

### Critical Data (Blocking - Must Load Before UI)

| Data | Source | Used By | Priority |
|------|--------|---------|----------|
| `hasCompletedOnboarding` | Hive `habit_data` box | Router redirect logic | P0 |
| `habits[]` | Hive `habit_data` box | TodayScreen, Dashboard | P0 |
| `focusedHabitId` | Hive `habit_data` box | AppState.currentHabit | P0 |
| `userProfile` | Hive `habit_data` box | Identity card, notifications | P0 |
| `appSettings` | Hive `habit_data` box | Theme, sounds, haptics | P0 |

### Secondary Data (Non-Blocking - Can Load Async)

| Data | Source | Used By | Priority |
|------|--------|---------|----------|
| `PsychometricProfile` | Hive `psychometric` box | LLM prompts, coaching style | P1 |
| `recoveryNeed` | Derived from Habit | Recovery banner UI | P1 |
| `consistencyMetrics` | Derived from Habit.completionHistory | GracefulConsistencyCard | P1 |
| Cloud sync state | Supabase (if configured) | Settings sync indicator | P2 |

---

## 2. Current Architecture: Dual State System

The app currently runs **two parallel state systems**:

### A. Legacy: AppState (Monolith)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            AppState (ChangeNotifier)                      │
│  lib/data/app_state.dart:51                                               │
├─────────────────────────────────────────────────────────────────────────┤
│  OWNS:                                                                    │
│  - _habits: List<Habit>                                                  │
│  - _userProfile: UserProfile?                                            │
│  - _settings: AppSettings                                                │
│  - _focusedHabitId: String?                                              │
│  - _hasCompletedOnboarding: bool                                         │
│  - _isPremium: bool                                                       │
│  - _currentRecoveryNeed: RecoveryNeed?                                   │
├─────────────────────────────────────────────────────────────────────────┤
│  DIRECT HIVE ACCESS:                                                      │
│  - _dataBox = Hive.openBox('habit_data')                                 │
│  - Reads/writes JSON via _loadFromStorage() / _saveToStorage()           │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │  Hive Box: 'habit_data'       │
                    │  (Single source of truth)     │
                    └───────────────────────────────┘
```

### B. Shadow: New Provider Architecture (Phase 34)

```
┌──────────────────────────────────────────────────────────────────────────┐
│                     Shadow Providers (Dark Launch)                        │
│  Initialized in main.dart but NOT consumed by UI yet                     │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐  │
│  │ SettingsProvider│    │  UserProvider    │    │   HabitProvider     │  │
│  │ (ChangeNotifier)│    │ (ChangeNotifier) │    │  (ChangeNotifier)   │  │
│  └────────┬────────┘    └────────┬─────────┘    └──────────┬──────────┘  │
│           │                      │                          │             │
│           ▼                      ▼                          ▼             │
│  ┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐  │
│  │HiveSettingsRepo │    │ HiveUserRepo     │    │  HiveHabitRepo      │  │
│  │ (Repository)    │    │ (Repository)     │    │  (Repository)       │  │
│  └────────┬────────┘    └────────┬─────────┘    └──────────┬──────────┘  │
│           │                      │                          │             │
│           └──────────────────────┴──────────────────────────┘             │
│                                  │                                        │
│                                  ▼                                        │
│                    ┌───────────────────────────────┐                      │
│                    │  Hive Box: 'habit_data'       │                      │
│                    │  (Shared with AppState!)      │                      │
│                    └───────────────────────────────┘                      │
└──────────────────────────────────────────────────────────────────────────┘
```

**Key Observation**: Both systems read from the SAME Hive box. This is intentional for the strangler fig migration.

---

## 3. Data Flow Diagram: App Launch to TodayScreen

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            APP LAUNCH SEQUENCE                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│  main.dart                                                                   │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                                              │
│  1. WidgetsFlutterBinding.ensureInitialized()                               │
│  2. await Hive.initFlutter()                         ◄── SYNC BOUNDARY      │
│  3. await Supabase.initialize()                      ◄── SYNC BOUNDARY      │
│  4. Initialize Repositories (Hive*Repository)                               │
│  5. Initialize Providers (SettingsProvider, etc.)                           │
│  6. appState = AppState()                                                    │
│  7. await appState.initialize()                      ◄── CRITICAL AWAIT     │
│  8. await Future.wait([                              ◄── PARALLEL INIT      │
│       settingsProvider.initialize(),                                         │
│       userProvider.initialize(),                                             │
│       habitProvider.initialize(),                                            │
│       psychometricProvider.initialize(),                                     │
│       jitaiProvider.initialize(),                                            │
│     ])                                                                        │
│  9. runApp(MultiProvider(...))                                               │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  AppState.initialize() (lib/data/app_state.dart:364)                        │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                                              │
│  1. await _notificationService.initialize()                                  │
│  2. await _homeWidgetService.initialize()                                    │
│  3. _dataBox = await Hive.openBox('habit_data')     ◄── HIVE OPEN           │
│  4. await _loadFromStorage()                         ◄── CRITICAL READ      │
│     ├── _hasCompletedOnboarding = box.get('hasCompletedOnboarding')         │
│     ├── _isPremium = box.get('isPremium')                                   │
│     ├── _settings = AppSettings.fromJson(box.get('appSettings'))            │
│     ├── _userProfile = UserProfile.fromJson(box.get('userProfile'))         │
│     ├── _focusedHabitId = box.get('focusedHabitId')                         │
│     └── _habits = box.get('habits').map(Habit.fromJson).toList()            │
│  5. if (hasCompletedOnboarding) await _scheduleNotifications()              │
│  6. _checkRecoveryNeeds()                            ◄── DERIVED STATE      │
│  7. await _processPendingWidgetCompletion()                                  │
│  8. await _updateHomeWidget()                                                │
│  9. _isLoading = false                                                       │
│  10. notifyListeners()                               ◄── UI CAN RENDER      │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  GoRouter Redirect (lib/config/router/app_router.dart:75)                   │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                                              │
│  initialLocation:                                                            │
│    appState.hasCompletedOnboarding ? '/dashboard' : '/bootstrap'            │
│                                                                              │
│  refreshListenable: Listenable.merge([appState, onboardingState])           │
│                                                                              │
│  _redirect() guards:                                                         │
│    1. checkCommitment() -> Permission guard                                 │
│    2. hasHolyTrinity -> Data integrity guard                                │
│    3. hasCompletedOnboarding -> Auth guard                                  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼ (if hasCompletedOnboarding)
┌──────────────────────────────────────────────────────────────────────────────┐
│  TodayScreen (lib/features/today/today_screen.dart)                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                                              │
│  build() {                                                                   │
│    Consumer<AppState>(                               ◄── WIDGET REBUILD     │
│      builder: (context, appState, child) {                                  │
│        final habits = appState.habits;                                      │
│        final profile = appState.userProfile;                                │
│        final isCompleted = appState.isHabitCompletedToday();               │
│        final recoveryNeed = appState.currentRecoveryNeed;                   │
│                                                                              │
│        return _HabitView(                                                    │
│          habit: habit,                                                       │
│          isCompleted: isCompleted,                   ◄── DERIVED            │
│          profile: profile,                                                   │
│        );                                                                    │
│      }                                                                       │
│    )                                                                         │
│  }                                                                           │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Widget Data Dependencies

### TodayScreen Widget Tree

```
TodayScreen
├── AppBar
│   └── pageIndicator (habits.length)
│
├── GuestDataWarningBanner
│   └── authService.isAuthenticated
│
├── IdentityCard
│   ├── profile.name
│   └── profile.identity
│
├── HabitCard
│   ├── habit.name
│   ├── habit.tinyVersion
│   ├── habit.implementationTime
│   ├── habit.implementationLocation
│   ├── habit.temptationBundle
│   ├── habit.environmentCue
│   ├── habit.environmentDistraction
│   ├── habit.isBreakHabit
│   ├── habit.substitutionPlan
│   └── isCompleted (derived)
│
├── GracefulConsistencyCard
│   ├── habit.consistencyMetrics    ◄── COMPUTED PROPERTY
│   │   ├── gracefulScore
│   │   ├── weeklyAverage
│   │   ├── monthlyAverage
│   │   └── neverMissTwiceRate
│   └── habit.identityVotes
│
├── RecoveryBanner (conditional)
│   └── appState.currentRecoveryNeed.urgency
│
├── RitualButton (conditional)
│   └── habit.preHabitRitual
│
├── CompletionButton
│   ├── isCompleted
│   └── habit.isBreakHabit
│
└── OptimizationTipsButton
```

---

## 5. Cloud Sync Architecture (Phase 63)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          DUAL-WRITE PATTERN                                  │
│                    (Local First, Cloud Async)                                │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  PsychometricProvider._saveAndSync()                                        │
│  lib/data/providers/psychometric_provider.dart:93                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. _profile = profile;                                                     │
│  2. await _repository.saveProfile(_profile);       ◄── LOCAL (BLOCKING)    │
│  3. notifyListeners();                             ◄── UI UPDATES          │
│  4. if (_cloudRepository != null) {                                         │
│       _cloudRepository.syncToCloud(_profile)       ◄── CLOUD (FIRE & FORGET)│
│         .then((_) => _repository.markAsSynced())                            │
│         .catchError((e) => debugPrint(...));                                │
│     }                                                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘


┌──────────────────────────────────────────────────────────────────────────────┐
│  SyncService: One-Way Backup Queue                                          │
│  lib/data/services/sync_service.dart                                        │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  syncHabit(habit) {                                                          │
│    if (!isSyncAvailable) {                                                   │
│      _queueOperation(SyncOperation(...));          ◄── QUEUE FOR LATER      │
│      return SyncResult.queued();                                             │
│    }                                                                         │
│    await supabase.from('habits').upsert({...});    ◄── CLOUD WRITE          │
│  }                                                                           │
│                                                                              │
│  Timer.periodic(5 minutes, (_) => _processSyncQueue());  ◄── RETRY LOOP     │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘


                    Cloud Tables (Supabase)
    ┌─────────────────────────────────────────────────┐
    │  habits              │  identity_seeds          │
    │  - id                │  - user_id               │
    │  - user_id           │  - anti_identity_label   │
    │  - name              │  - failure_archetype     │
    │  - tiny_version      │  - resistance_lie_label  │
    │  - completion_history│  - coaching_style        │
    │  - is_active         │  - hive_last_updated     │
    │  - updated_at        │  - sync_status           │
    └─────────────────────────────────────────────────┘
```

---

## 6. Identified Pain Points

### 6.1 Over-Fetching

| Issue | Location | Impact |
|-------|----------|--------|
| `consistencyMetrics` computed on every access | `Habit.consistencyMetrics` getter | O(N) where N = completion history length |
| Full habits list loaded even if viewing single habit | `AppState._loadFromStorage()` | Memory pressure with many habits |
| All shadow providers initialize even if unused | `main.dart:208` | ~100ms extra startup time |

### 6.2 Redundant Computations

| Computation | Frequency | Suggestion |
|-------------|-----------|------------|
| `ConsistencyMetrics.fromCompletionHistory()` | Every widget rebuild | Memoize in Habit model |
| `isHabitCompletedToday()` | Called multiple times per build | Cache in AppState |
| `currentMissStreak` calculation | Every `needsRecovery` check | Precompute on habit update |

### 6.3 Cache Invalidation Gaps

| Scenario | Current Behavior | Risk |
|----------|------------------|------|
| Habit completed via widget | Loads from Hive, updates AppState | Widget may show stale data briefly |
| Cloud sync conflict resolution | Cloud wins if newer by >1 minute | Local changes can be lost |
| Background notification action | Calls `completeHabitForToday()` | UI not updated until foregrounded |

---

## 7. Strangler Fig Seams

The following seams are available for incremental migration from AppState to new providers:

### Seam A: Settings

```
Current:  AppState._settings ─── Direct Hive ───> UI
Target:   SettingsProvider ──── Repository ────> UI

Migration:
1. Add Consumer<SettingsProvider> to SettingsScreen ✓ (ready)
2. Route themeMode, soundEnabled, etc. through SettingsProvider
3. Remove settings fields from AppState
4. Delete _settings from AppState._loadFromStorage()
```

### Seam B: User Profile

```
Current:  AppState._userProfile ─── Direct Hive ───> UI
Target:   UserProvider ────────── Repository ────> UI

Migration:
1. Add Consumer<UserProvider> to IdentityCard
2. Update setUserProfile() to use UserProvider
3. Inject UserProvider into HabitProvider for notifications
4. Remove _userProfile from AppState
```

### Seam C: Habits

```
Current:  AppState._habits ─── Direct Hive ───> TodayScreen
Target:   HabitProvider ─────── Repository ────> TodayScreen

Migration:
1. Use Consumer<HabitProvider> in TodayScreen (largest change)
2. Migrate completeHabitForToday() calls
3. Update Dashboard, History screens
4. Remove _habits from AppState (final step)
```

### Seam D: Psychometrics (Phase 63 Complete)

```
Current:  PsychometricProvider ─── Hive + Supabase ───> LLM prompts
Status:   MIGRATED ✓

Dual-write pattern established:
- Local Hive is primary (blocking)
- Supabase is secondary (async)
- Conflict resolution: cloud wins if newer by >1 minute
```

---

## 8. Recommended Optimizations

### Short-Term (No Architecture Changes)

1. **Memoize `consistencyMetrics`**: Cache in Habit model, invalidate on completion
2. **Precompute `isCompletedToday`**: Set boolean flag in `completeHabitForToday()`
3. **Lazy-load shadow providers**: Only initialize when first accessed

### Medium-Term (Strangler Fig)

1. **Migrate SettingsScreen** to use SettingsProvider (Seam A)
2. **Split AppState.initialize()** into parallel chunks
3. **Add loading skeletons** for secondary data

### Long-Term (Full Migration)

1. Complete Seam B (UserProvider)
2. Complete Seam C (HabitProvider) - largest effort
3. Deprecate AppState, remove from provider tree

---

## 9. Summary Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    RETURNING USER DATA FLOW SUMMARY                         │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │  Hive Box   │
    │ 'habit_data'│
    └──────┬──────┘
           │
    ┌──────┴──────┐
    │             │
    ▼             ▼
┌────────┐   ┌────────────┐
│AppState│   │Shadow Repos│   ◄── Both read same box
│(Legacy)│   │(Phase 34)  │
└────┬───┘   └─────┬──────┘
     │             │
     │             ▼
     │       ┌───────────┐
     │       │ Shadow    │
     │       │ Providers │   ◄── Not consumed by UI yet
     │       └───────────┘
     │
     ▼
┌─────────────────────────────────────────────────┐
│                   GoRouter                       │
│  refreshListenable: [appState, onboardingState] │
└────────────────────────┬────────────────────────┘
                         │
           ┌─────────────┼─────────────┐
           ▼             ▼             ▼
    ┌────────────┐ ┌───────────┐ ┌───────────┐
    │TodayScreen │ │ Dashboard │ │ Settings  │
    │ (Focus)    │ │ (List)    │ │ (Prefs)   │
    └────────────┘ └───────────┘ └───────────┘


    Cloud Sync (Async, Non-Blocking)
    ─────────────────────────────────
          │
          ▼
    ┌─────────────┐        ┌────────────────┐
    │ SyncService │───────>│   Supabase     │
    │ (Queued)    │        │ habits table   │
    └─────────────┘        └────────────────┘
          │
          ▼
    ┌─────────────────────┐        ┌────────────────┐
    │PsychometricProvider │───────>│   Supabase     │
    │ (Dual-Write)        │        │ identity_seeds │
    └─────────────────────┘        └────────────────┘
```

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-02 | Claude | Initial data flow mapping |
