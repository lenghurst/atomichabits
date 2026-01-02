# Data Flow Mapping: Returning User Experience

**Core Problem:** Ensure seamless re-engagement for users returning after a reinstall or device switch.
**Critical Fix (Phase 64):** "Cloud Hydration" implemented to solve the empty state issue on fresh installs.

---

## 1. The Critical Gap (Solved)

**Scenario:** User deletes app, reinstalls, signs in.
- **Before Fix:** Local Hive DB is empty. App shows "0 Habits". User thinks data is lost.
- **After Fix (Phase 64):** `AppState.initialize()` detects `isEmpty && isAuthenticated` -> Triggers `SyncService.hydrateFromCloud()`.
- **Result:** Habits are fetched from Supabase and repopulated into Hive before the dashboard loads.

---

## 2. High-Level Logic Flow

```mermaid
graph TD
    Boot[App Launch] --> Init[AppState.initialize]
    Init --> LoadHive[Load Hive (Local)]
    
    LoadHive --> CheckState{Is Hive Empty?}
    
    CheckState -- No (Data Exists) --> Ready[App Ready (Dashboard)]
    CheckState -- Yes --> CheckAuth{Is Authenticated?}
    
    CheckAuth -- No (New User) --> Onboarding[Go to Onboarding]
    CheckAuth -- Yes (Returning) --> Hydrate[SyncService.hydrateFromCloud]
    
    Hydrate --> SupabaseQuery[SELECT * FROM habits]
    SupabaseQuery --> MapData[Map to Local Models]
    MapData --> SaveHive[Save to Hive]
    SaveHive --> Ready
```

---

## 3. Component Data Flow

### A. Authentication (Identity Access Gate)
*   **Source:** `SupabaseAuth`
*   **State:** `UserProvider` (via `HiveUserRepository`)
*   **Persistence:** `hive_box('habit_data')` key: `userProfile`
*   **Flow:**
    1.  User signs in (Google/Email).
    2.  Supabase session established.
    3.  `UserProvider` fetches profile from Cloud if missing locally (Sync-on-Login).

### B. Habits (The Core Loop)
*   **Source:** Hive Box `habit_data` (Primary Source of Truth).
*   **Backup:** Supabase Table `habits`.
*   **Hydration Logic:**
    *   **Trigger:** `AppState.initialize`
    *   **Service:** `SyncService`
    *   **Method:** `hydrateFromCloud()`
    *   **Mapping:** `is_active` (DB) -> `!isPaused` (Local), `frequency_days` (DB) -> `frequency` (Local).

### C. Witness Events (Social Proof)
*   **Source:** Supabase Table `witness_events`.
*   **State:** `WitnessService`.
*   **Optimization (Phase 64):**
    *   **Lazy Load:** `initialize()` no longer awaits the fetch.
    *   **Fire-and-Forget:** Validation/fetching happens in background to unblock `main()`.

### D. Settings (Preferences)
*   **Source:** Hive Box `settings`.
*   **State:** `SettingsProvider` (migrated from `AppState`).
*   **Flow:**
    1.  `SettingsProvider` initializes from Hive.
    2.  UI updates immediately.
    3.  Changes persist to Hive.

---

## 4. Verification Checklist

| Scenario | Expected Outcome | Verified |
| :--- | :--- | :--- |
| **Fresh Install + Login** | Loader spins -> Habits appear -> Dashboard active | ✅ |
| **Offline Launch** | Data loads from Hive instantly | ✅ |
| **Profile Update** | Updates `UserProvider` + Hive + Supabase | ✅ |
| **Witness Startup** | App launches < 2s (no network block) | ✅ |

---

## 5. Technical Debt & Future Work

*   **Conflict Resolution:** Currently "Cloud Wins" on hydration. Future: Timestamp-based merge.
*   **Two-Way Sync:** Full bi-directional sync for multi-device usage (currently focused on restoration).
