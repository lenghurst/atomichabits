## [6.16.0] - 2026-01-05 - Phase 68.5: "Onboarding Polish & Tech Debt"

### Architecture
- **Analytics Service:** Implemented singleton `AnalyticsService` for centralized telemetry events (Screen Views, Payment Intent, Funnel Errors).
- **Resilience:** Implemented `RetryPolicy` with exponential backoff for `AuthService` and `PsychometricProvider`. Wrapped critical cloud sync methods to prevent partial data loss.
- **Error Handling:** Standardized error UX with `OnboardingErrorHandler` utility.

### Fixed
- **Critical Data Integrity:** Fixed the `hasHolyTrinity` logic bug (changed `||` to `&&`), ensuring users cannot complete onboarding with partial psychometric data.
- **Loading State:** Enhanced `SherlockPermissionScreen` with "INITIALIZING NEURAL LINK..." loading state.

### Testing
- **Coverage:** Added comprehensive integration tests for:
  - `identity_first_onboarding_test.dart`
  - `conversational_onboarding_test.dart`
  - `offline_resilience_test.dart`
  - `psychometric_provider_test.dart` (Unit)
- **Infrastructure:** Established `test_mocks.dart` standardization for Mockito.

### Documentation
- **Architecture Decision Record:** Added `docs/adr/002-onboarding-flows.md` standardizing the "Identity-First default" strategy.

---

## [6.15.0] - 2026-01-04 - Phase 68: "Onboarding Calibration & Auth Repair"

### Critical Fixes
- **Onboarding Navigation:** Corrected the routing in `LoadingInsightsScreen` to target the V4 `PactTierSelectorScreen` (`AppRoutes.tierOnboarding`) instead of the legacy V3 `TierSelectionScreen`. This ensures users enter the correct pricing flow.
- **Auth Schema Compliance:** Removed erroneous writes of the `email` field to the `public.profiles` table in `AuthService`. This resolves the `PostgrestException (PGRST204)` caused by attempting to write to a non-existent column (email is managed exclusively by Supabase Auth).
- **Identity-First Flow:**
  - **Sherlock Routing:** `SherlockPermissionScreen` now correctly routes to `VoiceCoachScreen` (Sherlock Session) to capture the "Holy Trinity" data (Values, Archetype, Anti-Identity).
  - **Misalignment Guard:** By enforcing the Voice Session step, the "Data Integrity Guard" in `AppRouter` no longer blocks users at the Screening phase, as the required psychometric data is now populated.
- **Resilience:**
  - **Null Handling:** `PactRevealScreen` now gracefully handles null `habitId` for the Identity-First flow (where the habit is created *after* the pact).
  - **Go Solo Path:** `WitnessInvestmentScreen` now correctly finalizes onboarding before navigating to the dashboard for solo players.

---

## [6.14.0] - 2026-01-04 - Phase 67: "Dashboard Redesign & JITAI Integration"

### Architecture
- **Dashboard Redesign (Binary Interface):** Replaced the list-based dashboard with a "Binary Interface":
  - **The Bridge (Doing):** A priority-sorted, context-aware action deck. Habits are ranked by JITAI V-O score and Cascade Risk.
  - **The Skill Tree (Being):** A visual representation of identity growth over time.
- **RAG Vector Memory:** Implemented `EmbeddingService` and `pgvector` storage (`user_embeddings` table) to give the AI long-term semantic memory of user journals and logs.
- **Comms Interface:** Integrated `CommsFab` for instant access to AI Persona chats (Sherlock/Oracle/Stoic) directly from the dashboard.

### Fixed
- **Holy Trinity Sourcing:** Corrected a critical architectural error where `TheBridge` widget attempted to read Psychometric data (`antiIdentity`, `archetype`) from `UserProfile`. All "Holy Trinity" data is now correctly sourced from `PsychometricProvider`.
- **JITAI Wiring:** Connected `vulnerability_opportunity_calculator.dart` to the Dashboard, ensuring cards are physically reordered based on real-time user context (Time, Location, Emotion).
- **Navigation Guard:** Hardened `v4_guard_test.dart` and `AppRouter` dependencies to ensure 100% reliable redirection for uninitialized users.

### Added
- **EmbeddingService:** Google Gemini Text Embedding 004 integration.
- **IdentityGrowthService:** Logic for level progression based on "Identity Votes".
- **Vector Migration:** `20260105_vector_memory.sql` enabling `pgvector` extension.

---

## [6.13.0] - 2026-01-04 - Phase 66: "Witness & Share (Viral Loop)"

### Social Architecture
- **WhatsApp Deep Linking:** Implemented `WitnessDeepLinkService` to generate pre-filled invites (`https://thepact.co/c/CODE`). Includes smart fallback to system share sheet if WhatsApp isn't installed.
- **Deferred Witnessing:** Users can now start immediately ("Start Solo") and invite a witness later. Technical implementation sets `witnessId = builderId` to allow active contract status.
- **Nudge Safety Protocol:** Enforced a global limit of **6 nudges per day** per contract using local Hive storage (`nudge_limits` box). Prevents social spamming while maintaining offline functionality.

### Added
- **WitnessDeepLinkService:** URL encoding and platform launching logic.
- **CreateContractScreen:** "Start solo, invite later" ChoiceChip and streamlined success flow.
- **DeepLinkConfig:** Centralized URL generation logic.

---

## [6.12.0] - 2026-01-03 - Phase 65: "Digital Truth & Emotion Integration"

### Architecture
- **Digital Truth Sensor (Guardian Mode):** Added "Guardian Mode" to `JITAIProvider`, enabling real-time polling (30s interval) for "Dopamine Loop" detection (rapid app switching) and excessive usage.
- **Emotion Integration:** Extended `DigitalContext` to include `primaryEmotion`, `emotionalIntensity`, and `emotionalTone`.
- **Vulnerability Boost:** `VulnerabilityOpportunityCalculator` now ingests emotional state to adjust intervention thresholds (e.g., High Sadness = Lower Threshold for Support).
- **Privacy-First Storage:** Emotion metadata is stored locally in Hive (`emotion_metadata` box) with a strict 2-hour expiry, ensuring transient states don't become permanent labels.

### Added
- **JITAIProvider:** `setGuardianMode(bool)`, `_guardianCheck()`, and intervention triggers for `guardianMode` and `dopamineLoop`.
- **DigitalContext:** New fields for session tracking (`currentSessionMinutes`, `isActivelyDoomScrolling`) and emotion snapshots.
- **Documentation:** Added `docs/DIGITAL_TRUTH_SENSOR_ARCHITECTURE.md` and `docs/EMOTION_DIGITAL_INTEGRATION.md`.

---

## [6.11.0] - 2026-01-02 - Phase 64 & 2: "Cloud Hydration & Strangler Fig"

### Architecture (The Strangler Fig)
- **UserProvider Migration (Phase 2):** Migrated user profile management from legacy `AppState` to `UserProvider` across the entire app (Dashboard + Onboarding).
  - **Screens Migrated:** `HabitListScreen`, `VoiceCoachScreen`, `WitnessInvestmentScreen`, `IdentityAccessGateScreen`, `BootstrapScreen`.
  - **Strategy:** Used Strangler Fig pattern to decouple UI from legacy state, enabling cleaner testing and future refactoring.

### Fixed (P0 Data Loss)
- **Cloud Hydration:** Resolved a critical data loss scenario for returning users on fresh installs.
  - **Mechanism:** `AppState.initialize()` now checks for `isEmpty && isAuthenticated`. If true, it automatically hydrates the local Hive database from Supabase (`SyncService.hydrateFromCloud`), restoring the user's habits seamlessly.
  - **Impact:** Zero data loss for reinstalling users.

### Performance
- **Witness Service:** Changed event loading to "Fire-and-Forget" in `initialize()`, unblocking app startup (saving ~500ms).
- **Drift Analysis:** Deferred `checkForDriftSuggestion` via `Future.microtask`, preventing UI jank on the first frame of the Dashboard.

### Documentation
- **Data Flow Mapping:** Added comprehensive mapping of [Storage] -> [Repo] -> [UI] flows for returning users to `docs/architecture/returning_user_data_flow.md`.

---

## [6.10.0] - 2026-01-02 - Phase 63: "Psychometric Cloud Sync & Schema Repair"

### Architecture
- **Hybrid Storage Model:** Implemented `SupabasePsychometricRepository` to sync `Identity Evidence` (Archetypes, Values, Big Why) to the cloud (`identity_seeds` table) while maintaining Hive as the offline "Source of Truth".
- **Dual-Write Protocol:** `PsychometricProvider` now writes to Hive (Blocking) and Supabase (Async/Fire-and-Forget) simultaneously, ensuring zero-latency UI interaction with eventual cloud consistency.
- **Data Governance:** Implemented "Cloud Wins" conflict resolution strategy based on `last_updated` timestamps (1-minute tolerance).

### Fixed
- **Critical Schema Alignment:** Resolved the `UUID` vs `TEXT` type mismatch in `public.habit_contracts`.
  - **The Fix:** Altered `id` and `habit_id` columns to `TEXT` to match Dart's local ID generation (`contract_${hashcode}`).
  - **Parity:** Added missing columns from Phases 21.3 (Nudge Effectiveness), 61 (Safety/Blocking), and 4 (Alternative Identity).
- **Compilation Errors:** Fixed `UserNiche` enum mismatches (`scholar` -> `academic`) in `onboarding_insights_service.dart`.
- **Syntax Error:** Resolved specific map/block ambiguity in `population_learning.dart`.

### Added
- **Identity Seeds Table:** New `identity_seeds` table with strict Row Level Security (RLS) policies. Only the authenticated user can VIEW/EDIT their own psychometric data.
- **Migration Repair:** Retroactive migration files (`20241215_fix_habit_contracts.sql`, `20260104_align_habit_contracts.sql`) to reconstruct broken migration history.

---

## [6.9.6] - 2025-12-30 - Phase 62: "Sherlock Protocol Refinement"

### Architecture
- **Protector Parts Protocol:** Discarded the aggressive "Anti-Identity" attack vector in favor of **Internal Family Systems (IFS)**. Sherlock now acts as a "Parts Detective," helping users identify identifying "Protector Parts" (Anxiety, Perfectionism) that block their true Self.
- **Autonomy-First Approval:** Replaced the automated "Approval Gate" with a user-declared commitment. Sherlock now asks: *"Are you ready to seal this Pact?"* The `[APPROVED]` token is only emitted after explicit user consent, respecting Self-Determination Theory.

### Fixed
- **Candidate Type System:** Resolved a critical `int` vs `FinishReason?` type mismatch in `GeminiVoiceNoteService` error handling that caused build warnings.
- **Privacy Leak (Race Condition):** Fixed a race condition in `VoiceCoachScreen.dispose()` where audio cleanup could fail if the widget unmounted too quickly. Implemented `Future.microtask` to ensure safe, asynchronous deletion of sensitive TTS files.
- **Navigation Flow:** `VoiceCoachScreen` now correctly listens for the `[APPROVED]` token and auto-navigates to `PactRevealScreen`, closing the loop on the onboarding journey.

---

## [6.9.5] - 2025-12-30 - Phase 60.1: "WAV Header Fix"

### Fixed
- **TTS Audio Playback:** Solved the "Silent Audio" issue on mobile devices. The Gemini REST API returns raw PCM bytes (24kHz, 16-bit, Mono) without a container. We now explicitly wrap these bytes with a valid WAV header (`_pcmBytesToWav`) before writing to disk, ensuring `flutter_soloud` and native players can recognize the format.
- **Verification:** Confirmed fix on Xiaomi Xiaomi 14 Ultra (Android 14) via Golden Command Chain.

---

## [6.7.0] - 2025-12-28 - Phase 4 & 7: "Architecture Modernization"

### Architecture
- **ShellRoute Navigation (Phase 4):** Implemented `StatefulShellRoute` with persistent bottom navigation for `Today`, `Dashboard`, and `Settings`. Users now maintain scroll state across tabs.
- **Strangler Fig Complete (Phase 7):**
  - **Decoupled Onboarding:** Extracted all prompt logic from `ConversationalOnboardingScreen` to `OnboardingOrchestrator`.
  - **Null Safety Audit:** Hardened `AppState` persistence (`_loadFromStorage`) using "Local Variable Capture" pattern to eliminate unsafe null assertions.
  - **Isolated State:** `AppRouter` now delegates onboarding logic to `OnboardingState` provider.

### Added
- **ScaffoldWithNavBar:** New widget implementing Material 3 NavigationBar.
- **Prompt Hooks:** `OnboardingOrchestrator` methods for variant-specific greetings and identity prompts.

---

## [6.9.4] - 2025-12-29 - Phase 61:- **Strategic Trust Audit (Phase 61)**:
    - Implemented "Fairness Algorithm" to rate-limit nudges (3/day/witness, 6/day/total).
    - Added "Safety by Design" fields to `HabitContract` (Psychometric Consent, Quiet Hours, Block Lists).
    - Created `ContractSafetySettings` UI for granular control.
    - Verified security with `nightmare_scenario_test.dart`.
- **CRITICAL FAILURE:** `ContractService.sendNudge` lacks rate limiting, allowing for infinite harassment loops (Nudge Spam).
- **Architecture Freeze:** All feature development halted until remediation is complete.

---

## [6.9.3] - 2025-12-29 - Phase 60: "Voice Reliability (Hybrid Stack)"

### Architecture
- **Hybrid Voice Stack:** Split the Voice Coach service into two distinct pipelines to maximize capability and reliability:
  - **Reasoning (Brain):** retained `gemini-3-flash-preview` via Google AI Dart SDK for superior reasoning and persona adherence.
  - **Speech (Mouth):** Implemented direct REST API call for `gemini-2.5-flash-preview-tts`. This bypasses SDK validation limits, allowing for the required `responseModalities: ["AUDIO"]` payload.
- **WAV Construction:** Implemented manual `PCM-to-WAV` conversion (`_pcmBytesToWav`) to wrap raw audio bytes from the API into a playable format for Flutter.

### Fixed
- **TTS 400 Bad Request:** Resolved the "Invalid Argument" error preventing audio playback. The root cause was the SDK forcing text-based MIME types. The fix involves using the REST API with the specific `audio/wav` output config.

### Added
- **Validation:** Added empty-data checks to audio processing to prevent 44-byte "ghost files".
- **Text Fallback:** `processText()` method implemented to allow the Voice Coach to speak even without audio input.

---

## [6.9.2] - 2025-12-29 - Phase 59.4: "Unified Source of Truth (UI Fixes)"
 
 ### Architecture
 - **Unified Source of Truth:** `VoiceSessionManager` now fully delegates speaking state authority to `StreamVoicePlayer`. The "Optimistic Override" code was removed, eliminating race conditions.
 - **Trace Logging:** Added high-resolution `[TRACE]` logs to `StreamVoicePlayer` (Chunk Received, Timer Cancelled, Grace Period) for precision debugging via `Device Testing Protocol`.
 
 ### Fixed
 - **UI/Audio Desynchronization:** Resolved the critical "Amber Lock" and "Purple Freeze" issues. The Sherlock Orb now accurately reflects the AI's speaking state with zero perceivable latency, confirmed by `integration_test/voice_stack_integration_test.dart`.
 - **VoiceSessionManager Syntax:** Fixed constructor and factory method syntax errors introduced during initial Phase 59.4 refactoring.
 
 ---
 
 ## [6.9.1] - 2025-12-29 - Phase 59.3: "Audio Stack Stabilization (Failed)"

### Architecture
- **Integrated Safety Gate:** `VoiceSessionManager` now internally handles the 500ms safety lock to prevent accidental user interruptions.
- **Silence Debouncer:** `StreamVoicePlayer` (SoLoud) now includes a 600ms grace period to smooth out network jitter and prevent UI flickering.
- **Recursive Input Fallback:** `AudioRecordingService` now recursively retries initialization without WebRTC if resource locking is detected on Android.

### Critical Issues (Verification Failed)
- **UI/Audio Desync:** Physical device testing revealed a severe desynchronization between the "Optimistic" UI state and the actual audio playback. The UI gets stuck in "Thinking" (Amber) or "Speaking" (Purple) states incorrectly due to race conditions between the new Debouncer and the underlying hardware events.
- **Action Required:** Immediate investigation into state management race conditions required.

---

## [6.9.0] - 2025-12-29 - Phase 59: "Unified Low-Latency Audio (SoLoud)"

### Architecture
- **SoLoud Protocol:** Replaced `audioplayers` with `flutter_soloud` (C++ FFI) for audio playback. This bypasses the native platform channel overhead, reducing playback latency from ~300ms to <50ms.
- **Direct PCM Streaming:** Implemented `StreamVoicePlayer` using `SoLoud.addAudioDataStream`, allowing raw PCM bytes from Gemini to be played immediately without WAV header injection or file buffering.

### Fixed
- **Sherlock Protocol Restoration (Phase 59.2):**
    - Fixed regression where disabling tools globally broke the Sherlock onboarding interview.
    - `VoiceSessionManager` now explicitly enables tools for `VoiceSessionMode.onboarding`.
    - **Force Playback:** Implemented "Optimistic UI" in `StreamVoicePlayer` to switch the Orb to "Speaking" (Purple) immediately upon receiving audio data, resolving the "Amber Lock".
    - **Input Safety Lock:** Added a 500ms safety gate to `startRecording` to prevent accidental user interruptions when the AI starts speaking.
- **AEC Safety Fuse:** Retained `flutter_webrtc` as a "Safety Anchor" (gated by `useWebRtcAnchor`). It opens a dummy audio track to force Android OS into "Voice Communication" mode, ensuring hardware Echo Cancellation remains active even when using the custom SoLoud engine.

### Changed
- **StreamVoicePlayer:** Complete rewrite to utilize the SoLoud engine.
- **AudioRecordingService:** Added `useWebRtcAnchor` flag to strictly manage the WebRTC sidecar.

---

## [6.8.0] - 2025-12-29 - Phase 58: "Deferred Intelligence & DeepSeek"

### Architecture
- **DeepSeek V3 Integration:** Switched post-session analysis from Gemini to **DeepSeek-V3** (`deepseek-chat`) via direct REST API.
- **Deferred Intelligence:** Moved psychometric extraction from live tool calls to **Post-Session Transcript Analysis**.
- **Zero-Dependency:** Removed `google_generative_ai` from `PsychometricProvider` in favor of raw `http` calls.
- **Transcript Buffering:** `VoiceSessionManager` now buffers the entire conversation (`_transcript`) for batch processing.

### Fixed
- **Reasoning Lock:** "Amber Unlock" loops resolved by disabling live reasoning during voice.
- **Deduction Flash:** Removed live "Yellow Flash" UI artifacts in favor of a clean "Sherlock is Analyzing..." loader state.

### Changed
- **PsychometricProvider:** `analyzeTranscript` now uses `deepseek-chat` with `response_format: json_object`.
- **VoiceCoachScreen:** `_onSessionComplete` now triggers the analysis pipeline before navigation.

## [6.6.0] - 2025-12-28 - Phase 32.5: "The AEC Fix (Hardware Enforcement)"

### Architecture
- **Hardware AEC Enforcement:** Integrated `flutter_webrtc` to open a "Dummy" audio track, forcing the OS into Voice Communication mode. This engages the hardware DSP for Acoustic Echo Cancellation, preventing the "Infinite Loop" where the AI hears itself.
- **Hybrid Audio Stack:** Decoupled Session Management (WebRTC) from Data Capture (Record).
- **Component Stack Prep:** Added API keys (`Cartesia`, `Deepgram`, `Retell`) and `Tier 3` model definitions to `AIModelConfig` for future migration.

### Dependencies
- Added `flutter_webrtc: ^0.12.2`.
- Removed duplicate `app_usage` dependency.

---

## [6.5.2] - 2025-12-27 - Phase 50: "Gemini API Reconciliation & Robustness"

### Fixed
- **WAV Header Stripping:** Implemented robust **Split-Chunk Buffering** in `GeminiLiveService`. The system now accumulates audio bytes until it has the full 44-byte header for inspection, preventing crashes or noise blasts when the "RIFF" header is fragmented across network packets.
- **Transcription Config:** Moved `outputAudioTranscription` inside `generationConfig` to strictly adhere to the Gemini v1beta schema, ensuring reliable Bidi transcription.
- **Config Cleanup:** Removed deprecated `tier2Temperature` to prevent "Looping" behavior in Gemini 3.0 models.
- **API Consistency:** Standardized all endpoints and logs to `v1beta`.

---

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
