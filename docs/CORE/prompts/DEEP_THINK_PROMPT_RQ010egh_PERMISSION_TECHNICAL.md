# Deep Think Prompt: RQ-010egh — Permission Technical (Architecture)

> **Parent RQ:** RQ-010 — Permission Data Philosophy
> **This Sub-RQ Group:** RQ-010e, RQ-010g, RQ-010h
> **SME Domain:** Mobile Systems Architecture & Android Engineering
> **Prepared:** 15 January 2026
> **For:** Google Deep Think / Claude Projects
> **App Name:** The Pact

---

## Your Role

You are a **Lead Android Systems Architect** specializing in:
- Background sensor processing & battery optimization
- Android Sensor API (Sleep API, Activity Recognition, Geofencing)
- Privacy-preserving architecture
- Fault-tolerant systems

Your approach: Think in terms of "Signal-to-Noise" and "Cost-per-Bit." Every sensor poll costs battery. Every permission request costs trust. Optimize for the "Minimum Viable Signal."

---

## PART 1: WHAT IS "THE PACT"? (Essential Context)

**You have no prior knowledge of this project. This section provides essential context.**

### The App in One Paragraph

The Pact is a mobile app (Flutter, Android-first) that helps users build identity-based habits through psychological insight and social accountability. It helps users manage multiple "identity facets" (e.g., "The Writer," "The Parent") managed by a "Parliament of Selves."

### Core Philosophy: "psyOS" (Psychological Operating System)

- **JITAI (Just-In-Time Adaptive Intervention):** The engine monitors context (location, time, energy) to recommend the *right* habit for the *current* facet.
- **Passive Energy Detection:** We infer "Energy State" (Focus, Physical, Social, Recovery) from sensors to prevent burnout.
- **State Economics:** Switching identities costs energy. We model this cost.

### Key Terminology

| Term | Definition |
|------|------------|
| **JITAI** | Just-In-Time Adaptive Intervention. The "Agency Engine." |
| **Signal Fading** | The decay of confidence in a user's state over time. |
| **Geofence** | A virtual perimeter for real-world geographic areas (e.g., Work, Gym). |
| **Activity Recognition** | Android API that returns `Still`, `Walking`, `InVehicle`, etc. |
| **Battery Budget** | The maximum allowed daily battery drain (< 5%). |

### Tech Stack

- **Frontend:** Flutter 3.38.4 (Android-first)
- **Backend:** Supabase (PostgreSQL + pgvector)
- **Local:** Hive (NoSQL) for sensor cache
- **State:** Riverpod

---

## Mandatory Context: Locked Architecture

### CD-017: Android-First ✅
- **Constraint:** We are optimizing for Android ecosystem APIs (Play Services, Activity Recognition API). iOS is secondary.

### RQ-014: Passive Energy Detection ✅
- **Algorithm Sensitivity (The "Why"):**
    - **Activity Recognition (40% Weight):** High confidence signal. If we lose this, we can't distinguish "Walking" (Social/Active) from "Still" (Focus).
    - **Calendar (40% Weight):** Contextual signal.
    - **Biometric (20% Weight):** Validation signal.
- **Implication:** Losing Activity Recognition creates a 40% blind spot. We need to fight for this permission or find a proxy.

### RQ-010a: Accuracy Model ✅
- **Baseline:** We established that without sensors, we are guessing. With sensors, we have ~85% confidence.

---

## Research Question Group: RQ-010egh — Permission Technical

### Core Problem
We have a "Hungry AI" (needs data) and a "Finite Battery/User" (limited resources). We cannot poll GPS every 10 seconds. We cannot ask for 15 permissions.

**We need a technical architecture that delivers sufficient JITAI accuracy with minimal battery impact and the smallest possible permission footprint.**

### Sub-Questions (Answer Each Explicitly)

| # | ID | Question | Your Task |
|---|----|----------|-----------|
| 1 | **RQ-010g** | **MVP Permission Set:** What is the ABSOLUTE minimum set required for v1? | Define the "Critical Path" sensors. Discard "Nice-to-Haves." (e.g., Do we *really* need Precise Location, or is Coarse + Geofence enough?) |
| 2 | **RQ-010h** | **Battery vs. Accuracy:** What are the tradeoffs? | Create a "Sampling Strategy." How often do we poll? Push (Listener) vs Pull (Polling)? Analyze the battery cost of Activity Recognition vs Geofencing. |
| 3 | **RQ-010e** | **Flexibility Impact:** How does missing data affect JITAI accuracy? | Analyze the algorithm from RQ-014. If `Activity` is missing, how much does confidence drop? Design the "Confidence Fallback" logic. |

### Anti-Patterns to Avoid
- ❌ **"Always On" GPS**: Polling GPS continuously (battery killer).
- ❌ **Precise Location Dependency**: Relying on 10m accuracy when 500m (Geofence) suffices.
- ❌ **Main Thread Processing**: Handling sensor streams on the UI thread.
- ❌ **Ignoring Doze Mode**: Failing to account for Android's background restrictions.

---

## Output Required

1.  **The MVP Sensor Manifest (RQ-010g)**
    - List of permissions (Exact Android Manifest names).
    - Justification for each (Why is it critical?).
    - "Cut Line": What did you exclude and why?

2.  **The Battery Budget / Sampling Strategy (RQ-010h)**
    - Table: Sensor → Method (Push/Pull) → Frequency → Est. Battery %.
    - Strategy for "Doze Mode" and "App Standby."

3.  **The Confidence Fallback Logic (RQ-010e)**
    - Pseudocode or Flowchart.
    - `calculateConfidence(availableSignals)` function structure.
    - How does the system flag "Low Confidence" to the user?

4.  **Confidence Assessment**
    - Rate each recommendation HIGH/MEDIUM/LOW.

---

## Technical Constraints (Hard Requirements)

| Constraint | Rule |
|------------|------|
| **Battery Cap** | Total daily drain MUST be < 5%. |
| **Android 13+** | Must use `POST_NOTIFICATIONS`, `BODY_SENSORS`, `ACTIVITY_RECOGNITION` appropriately. |
| **Offline First** | Sensor data must be processed locally first (Hive), then synced context to cloud. |
| **Privacy Scope** | **ALLOWED:** Android System Intelligence (Google Play Services) processing on-device. **FORBIDDEN:** Exfiltrating raw GPS/Sensor arrays to *our* backend. We only sync the *Inferred State* (e.g., "User is RUNNING"). |

---

## Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Efficient** | Is the sampling rate justified? |
| **Robust** | Does it handle sensor unavailability (e.g., user turns off GPS)? |
| **Safe** | Does it respect the "Raw Data Local Only" rule? |

---

## Final Checklist Before Submitting

- [ ] Permissions list uses exact Android constants (e.g., `ACCESS_FINE_LOCATION`).
- [ ] Battery impact estimated for "High" vs "Low" accuracy modes.
- [ ] Fallback logic defined for missing sensors.
- [ ] Privacy constraint (Local Processing) strictly adhered to.

---
*End of Prompt*
