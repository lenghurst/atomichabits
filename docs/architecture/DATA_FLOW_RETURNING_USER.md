# Data Flow Mapping: Returning User Landing Page

## 1. Executive Summary

The **Returning User Landing Page** (`HabitListScreen`) relies almost exclusively on **Local-First (Hive)** architecture. This ensures instant load times and offline resilience but currently creates a **Data Silo** where cloud changes (from other devices or background processes) are not reflected in the UI.

- **Primary Data Source**: Local Hive Box (`habit_data`)
- **Sync Strategy**: Local-First with Cloud Hydration
- **Status**: ✅ P0 Sync Gap FIXED (2026-01-02)

---

## ✅ RESOLVED: Cloud Hydration Implemented

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     ✅ REINSTALL = DATA RESTORED ✅                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  FIXED: SyncService.hydrateFromCloud() now restores habits on fresh install │
│                                                                              │
│  TRIGGER CONDITIONS:                                                         │
│  1. Local Hive is empty (no habits)                                         │
│  2. User is authenticated                                                    │
│  3. SyncService and AuthService are available                               │
│                                                                              │
│  SCENARIO (NOW): User gets new phone → Installs → Logs in → Data Restored!  │
│                                                                              │
│  IMPLEMENTATION:                                                             │
│  - SyncService.hydrateFromCloud() fetches active habits from Supabase       │
│  - Maps snake_case (cloud) → camelCase (Habit model)                        │
│  - Persists to Hive immediately for fast future launches                    │
│  - 10-second timeout to avoid blocking UI                                   │
│  - Graceful fallback if network fails                                        │
│                                                                              │
│  FILES CHANGED:                                                              │
│  - lib/data/services/sync_service.dart (hydrateFromCloud, field mapping)    │
│  - lib/data/app_state.dart (hydration check in initialize())                │
│  - lib/main.dart (pass syncService/authService to AppState)                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Core Data Flow Ecosystem

```mermaid
graph TD
    %% Subgraphs for Layers
    subgraph Storage [Storage Layer]
        Hive[("📦 Hive (Local)\nbox: habit_data")]
        Supabase[("☁️ Supabase (Cloud)\ntables: habits, contracts")]
    end

    subgraph Service [Service Layer]
        AppState[("🧠 AppState\n(ChangeNotifier)")]
        SyncService["🔄 SyncService\n(Background Queue)"]
        WitnessService["👁️ WitnessService\n(Realtime Channel)"]
        ContractService["📜 ContractService\n(On-Demand)"]
    end

    subgraph UI [UI Layer]
        Landing["📱 HabitListScreen\n(Dashboard)"]
        Nav["🧭 AppRouter\n(Navigation)"]
    end

    %% Flows
    Hive == "(1) Sync Load (Startup)" ==> AppState
    AppState -- "(2) Provider Notification" --> Landing
    
    %% User Actions
    Landing -.->|"(3) Complete Habit"| AppState
    AppState -.->|"(4) Persist"| Hive
    
    %% Cloud Flows (Disconnected from Read Loop)
    AppState -.->|"(5) Trigger Backup"| SyncService
    SyncService -.->|"(6) Upsert (Async)"| Supabase
    Supabase -.->|"(7) Realtime Events"| WitnessService
    
    %% NEW: Cloud Hydration (P0 Fix)
    Supabase ==|"(8) ✅ hydrateFromCloud()\n(if local empty)"| SyncService
    SyncService ==|"(9) Restore habits"| AppState
    
    %% Styles
    linkStyle 0 stroke-width:4px,stroke:green,color:green;
    linkStyle 1 stroke-width:4px,stroke:green,color:green;
    linkStyle 4 stroke-width:2px,stroke:orange,stroke-dasharray: 5 5;
    linkStyle 5 stroke-width:2px,stroke:orange,stroke-dasharray: 5 5;
    linkStyle 8 stroke-width:4px,stroke:green,color:green;
    linkStyle 9 stroke-width:4px,stroke:green,color:green;
```

---

## 4. Data Flow Annotations

### Flow A: The "Instant Launch" Path (Critical Path)
**Goal**: Render Dashboard for Returning User.
1.  **[Storage] Hive** (`habit_data`) reads `hasCompletedOnboarding`, `habits`, `userProfile` into memory.
    *   *Type*: Synchronous (effectively, via Hive memory cache).
    *   *Location*: `AppState.initialize()` -> `_loadFromStorage()`.
2.  **[State] AppState** populates `_habits` List and `_userProfile`.
3.  **[State] AppState** notifies listeners.
4.  **[UI] HabitListScreen** rebuilds via `Consumer<AppState>`.
    *   *Dependency logic*: `appState.habitsWithStacks` (computes stack indentation).

### Flow B: The "Cloud Backup" Path (Background)
**Goal**: Persist data to Supabase for recovery.
1.  **[User]** completes a habit on UI.
2.  **[State] AppState** updates local state & Hive.
3.  **[State] AppState** calls `SyncService.syncCompletion()`.
4.  **[Service] SyncService** adds to `_syncQueue` (memory).
5.  **[Service] SyncService** attempts async `Supabase.insert`.
    *   *Constraint*: **One-Way Only**. `AppState` never reads *back* from `SyncService` or Supabase to update local habits.

### Flow C: The "Witness" Path (Sidecar)
**Goal**: Social Accountability.
1.  **[Service] WitnessService** initializes.
2.  **[Service]** calls `Supabase.from('witness_events').select()`.
3.  **[Service]** subscribes to `supaBase.channel()`.
    *   *UI Impact*: Does **not** affect `HabitListScreen` rendering directly. Notifications may appear as Toasts/Badges.

---

## 5. Key Questions Answered

### 1. What data does a returning user need to see?
*   **Habit List**: Name, status (completed today?), streak, stack position.
*   **User Profile**: Identity statement ("I am a Writer").
*   **Consistency Metrics**: "Graceful Score", Weekly Average.
*   **Notifications**: Pending witness actions (currently hidden/toasted).

### 2. Where does that data come from?
*   **100% Hive (Local)** for the core Dashboard experience.
*   Supabase is currently only a **Write Sink** (Backup).

### 3. Current Flow through AppState
*   `main.dart` -> `AppState.initialize()` -> `Hive.openBox` -> `_loadFromStorage` -> `_habits` (List).
*   **Monolithic State**: `AppState` holds the entire active user session.

### 4. Pain Points / Redundancies
*   **🔴 The Sync Gap**: There is **Zero** read-path from Supabase to AppState for Habits.
    *   *Consequence*: If I reinstall the app, "Factory Reset", or use a second device, my Dashboard will be **Empty** or stale, even though data exists in Supabase.
    *   *Fix*: Need a `SyncService.pullFromCloud()` on startup or a "Strangler Fig" Repository that checks Cloud vs Local timestamps.
    *   **Status**: ✅ **RESOLVED** (v1.2) via `hydrateFromCloud()` implementation.
*   **Over-Fetching (Witness)**: `WitnessService` loads 50 events on every startup (via `initialize()`), even if the user never navigates to the Witness Dashboard. This delays generic app startup performance.
    *   **Status**: ✅ **OPTIMIZED** (v1.2.1) via Fire-and-Forget implementation in `initialize()`.
*   **Drift Analysis Latency**: `TodayScreenController.checkForDriftSuggestion` runs on the UI thread and processes the entire completion history. For long-time users, this computation causes frame drops (jank) during the critical first render of the dashboard.
*   **Sync-Blocking-UI Risk**: While `AppState.initialize` is async, it awaits `Hive.openBox`. If Hive box is corrupted or large, it delays the `runApp` (or strictly speaking, the `isLoading` state in `MyApp`).

---

## 6. Strangler Seams

| Feature | Current | Proposed Seam |
| :--- | :--- | :--- |
| **Habit Data** | `AppState` uses raw Hive box | Inject `HabitRepository` that abstracts Hive + Supabase (Dual Read) |
| **Commitment** | `AppState` flags | Already delegating to `OnboardingState` (The Fig is working) |
| **Witness** | `WitnessService` (Standalone) | Keep standalone, but integrate badge count into `HabitListScreen` |

## 7. Recommended Optimizations

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

## 8. Summary Diagram

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
| 1.0 | 2026-01-02 | Antigravity | Initial data flow mapping |
| 1.1 | 2026-01-02 | Antigravity | Added: Critical Gap warning, Mermaid diagram, WitnessService over-fetching, Drift Analysis latency |
| 1.2 | 2026-01-02 | Antigravity | **P0 FIX**: Implemented cloud hydration - SyncService.hydrateFromCloud() + AppState integration. Sync gap RESOLVED. |
