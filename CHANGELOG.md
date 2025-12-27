## [6.5.1] - 2025-12-27 - Phase 49: "Sherlock Screening & Thinking Fixes"

### Fixed
- **AI Amnesia:** Fixed a critical bug where the AI forgot context across turns. Specifically, `thoughtSignature` is now correctly extracted from server responses and echoed back, ensuring the AI remembers persona instructions (e.g., "Homeless Man").
- **Thinking Mode:** Audit confirmed "Thinking Mode" is ON by default for `gemini-2.5-flash-native-audio-preview-12-2025`. Decision made to KEEP it enabled for Sherlock Screening to ensure higher accuracy and reasoning depth.
- **UI Terminology:** Renamed "The Interrogation" / "Voice Coach" header to "**SHERLOCK SCREENING**" during the onboarding phase for clarity.

### Added
- **Sherlock Screening:** Formalized the initial voice interaction as a distinct "Sherscreening" phase with Always-On VAD.

---

## [6.5.0] - 2025-12-27 - Phase 48: "Voice Note Style UI"

### Changed
- **UI Overhaul:** Refactored `VoiceCoachScreen` to separate the Visualizer (Sherlock's Avatar) from the Microphone Control.
- **Interaction Model:** Replaced single "Orb" tap with a dedicated Microphone Button:
  - **Hold-to-Talk:** Press and hold to speak, release to send (Voice Note style).
  - **Tap-to-Lock:** Tap once to lock microphone on, tap again to send.
- **Feedback:** Added explicit state labels ("Sherlock Speaking", "Hold to Speak or Tap to Lock") and distinct visual cues (Green Arrow for Send, Red/Pulse for Talk).

---

## [6.4.8] - 2025-12-27 - Phase 47.2: "Manual Turn-Taking (Tap-to-Talk)"

### Added
- **Manual Turn-Taking:** Implemented "Tap to Send" logic in `VoiceCoachScreen`. Tapping the orb while listening now explicitly commits the turn, pauses the microphone, and forces a server response.
- **Explicit Mic Control:** ensuring the microphone is physically paused during the "Analysing..." phase to prevent "Sticky VAD" issues.

---

## [6.4.7] - 2025-12-27 - Phase 47.1: "VAD Calibration & UI Reliability"

### Fixed
- **Sticky VAD:** Implemented **DC Offset Removal** and **Component-Level Adaptive Thresholding** in `AudioRecordingService`. The VAD now dynamically learns the room's noise floor (starting at 0.02) to prevent getting stuck in "Listening" mode due to hardware bias or background noise.
- **UI Zombie State:** Fixed a race condition in `VoiceCoachScreen` where interrupting the AI (or echo) left the UI stuck saying "SHERLOCK SPEAKING". User input now immediately overrides AI playback state.
- **AI Phrasing:** Added negative constraints to `ai_prompts.dart` to suppress filler phrases like "I hear you" or "I understand".

### Added
- **Detailed VAD Logging:** `[VAD] RMS | Floor | Thresh` logs for real-time calibration.

---

## [6.4.6] - 2025-12-26 - Phase 45.4: "Onboarding & Persistence Fixes"

### Fixed
- **Google Sign-In Bypass:** Corrected the redirect in `IdentityAccessGateScreen` to target `AppRoutes.onboardingPermissions` instead of `sherlockPermissions`, ensuring users enter the full onboarding pipeline.
- **Factory Reset Persistence:** Enhanced `AppState.clearAllData()` to explicitly sign out of the Supabase cloud session, preventing "zombie" authenticated states after a reset.
- **Tier Selection Loop:** Fixed the "Standard Protocol" button in `TierSelectionScreen` to route to `AppRoutes.manualOnboarding` instead of `home`, preventing infinite onboarding loops.

---

## [6.4.3] - 2025-12-26 - Phase 46.1: "Security & Clean Code"

### Security
- **Secure Configuration:** Introduced `Env` class for build-time secret injection (`GEMINI_API_KEY`, `SUPABASE_URL`, etc.).
- **Backdoor Removal:** Removed legacy "Oliver Backdoor" implementation and comments from `AppState`.
- **API Hardening:** Removed hardcoded API key placeholders from `GeminiChatService` and `AiSuggestionService`.

---

## [6.4.5] - 2025-12-26 - Phase 47: "Sherlock Expansion (God View)"

### Added
- **Environmental Layer:** Introduced `EnvironmentalSensor` using `geolocator` for contextual awareness (e.g., Gym, Bar).
- **Biometric Layer:** Integrated `BiometricSensor` using `health` to monitor Sleep and HRV (Heart Rate Variability).
- **Digital Truth Layer:** Implemented `DigitalTruthSensor` (Android) using `app_usage` to detect high-dopamine app usage ("Doomscrolling").
- **Psychometric Engine Upgrade:** Engine now ingests physiological data (Sleep < 6h, Low HRV, High Digital Distraction) to dynamically adjust `Resilience Score` and `Coaching Persona`.

### Changed
- **Permissions:** Updated `Info.plist` (iOS) and `AndroidManifest.xml` (Android) with Location, Health, and Usage Stats permissions.

---

## [6.4.4] - 2025-12-26 - Phase 46.3: "Sherlock Sensors"

### Added
- **Psychometric Profiling Scopes:** Extended Google Sign-In to request `calendar.readonly`, `youtube.readonly`, `tasks.readonly`, `fitness.activity.read`, and `user.birthday.read`.
- **Purpose:** Enables the "Sherlock Protocol" to detect behavioral patterns (Overcommitting, Dopamine Addiction, Hoarding) directly from user data.

---

## [6.4.2] - 2025-12-26 - Phase 46.2: "iOS Platform Alignment"

### Fixed
- **iOS Build Failure:** Restored missing `ios/Podfile` with critical `permission_handler` macros (`PERMISSION_MICROPHONE=1`, `PERMISSION_CONTACTS=1`).
- **Privacy Crash:** Added missing `NSMicrophoneUsageDescription` to `Info.plist`, preventing immediate crash on voice recording attempt.
- **Dependency Parity:** Aligned iOS native configuration with Android's feature set (Audio, Contacts, Deep Links).

---

## [6.4.1] - 2025-12-26 - Phase 46: "Audit Remediation & Cleanup"

### Fixed
- **Deprecation Cleanup:** Replaced all instances of `Color.withOpacity` with the modern `Color.withValues(alpha: ...)` across `PactRevealScreen` and `PactTierSelectorScreen`.
- **Real-Time Diagnostics:** Upgraded `VoiceProviderSelector` diagnostics from real network latency testing.
- **Sherlock Intelligence:** `PactRevealScreen` now displays *real* psychometric traits (Anti-Identity, Archetype, Lie) parsed from Text Chat conversations, replacing the fallback data.

### Architecture
- **Robustness:** Added network timeout (5s) to voice provider pings to prevent UI hangs.
- **Data Plumbing:** Added "Holy Trinity" fields to `OnboardingData` and wired `PsychometricProvider` to ingest them from standard onboarding flows.

---

## [6.4.0] - 2025-12-26 - Phase 46: "Voice Architecture Simplification"


### Architecture
- **Simplified Voice Stack:** Removed Supabase Edge Function dependency for voice tokens; defaulting to direct API key usage for launch.
- **Provider Abstraction:** Introduced `VoiceApiService` interface to support multiple AI providers (Gemini, OpenAI).
- **OpenAI Integration:** Added `OpenAILiveService` implementing the OpenAI Realtime API (WebSocket).
- **Diagnostics Tool:** Implemented real network latency testing in `VoiceProviderSelector` to compare provider performance.

### Added
- **VoiceApiService:** New abstract interface for voice communication.
- **OpenAILiveService:** Implementation of OpenAI Realtime API.
- **Diagnostics Tool:** Triple-tap header -> DevTools -> "Test Voice Connection" now pings real servers.
- **Latency Metrics:** `measureLatency()` added to all voice services.

### Changed
- **VoiceSessionManager:** Updated to use `VoiceApiService` and dynamically select provider based on configuration.
- **GeminiLiveService:** Refactored to implement `VoiceApiService` and added `measureLatency()`.
- **DevToolsOverlay:** Updated "View Logs" and added "Test Voice Connection".

---

## [6.3.4] - 2025-12-26 - Phase 45: "Cloud Sync Preparation"

### Architecture
- **Sync-Ready Psychometrics:** `PsychometricProfile` now tracks its own sync state to prepare for upcoming Supabase integration
- **Dirty State Management:** `PsychometricProvider` automatically marks profiles as "not synced" whenever modifications occur (via tools or user input)

### Added
- **PsychometricProfile:** Added `isSynced` (bool) and `lastUpdated` (DateTime) fields
- **PsychometricRepository:** Added `markAsSynced()` method to interface and Hive implementation
- **Unit Tests:** Created `psychometric_sync_test.dart` to verify state transitions

### Changed
- **PsychometricProfile:** Removed `const` constructor to support `DateTime.now()` as default `lastUpdated` timestamp
- **PactRevealScreen:** Updated fallback profile to use `static final` instead of `const`

---

## [6.3.3] - 2025-12-26 - Phase 45: "User Data Unification & Flow Fix"

### Architecture
- **Unified User Data:** `isPremium` status moved from standalone Hive key to `UserProfile` model
- **Migration Engine:** `HiveUserRepository` automatically migrates legacy data on next launch
- **Source of Truth:** `UserProvider` now relies solely on `UserProfile` for premium status

### Fixed
- **Onboarding Route Gap:** `PactRevealScreen` (the "Magic Moment") was disconnected from the manual onboarding flow.
- **Navigation Loop:** Both `PactTierSelectorScreen` (manual flow) and `ConversationalOnboardingScreen` (chat flow) now correctly route to `PactRevealScreen` before entering the Dashboard.

### Changed
- **UserProfile:** Added `isPremium` field (defaults to false)
- **UserProvider:** Removed `_isPremium` state, now derived from profile
- **HiveUserRepository:** Added migration logic in `getProfile()`
- **Registration Deferral:** `AppState.completeOnboarding()` is now solely handled by `PactRevealScreen`, ensuring the variable reward is always seen.

### Technical Details (The Strangler Pattern)
- Simplifies state management by having a single source of truth for user identity
- Resolves data fragmentation between Identity and Subscription status
- Prepares for eventual removal of legacy `AppState`
